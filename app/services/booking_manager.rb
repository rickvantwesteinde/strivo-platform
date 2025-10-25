class BookingManager
  class BookingError < StandardError; end

  def initialize(session:, user:)
    @session = session
    @user = user
  end

  def book!
    raise BookingError, I18n.t('storefront.bookings.full', default: 'Deze sessie is vol.') if session.full?
    raise BookingError, I18n.t('storefront.bookings.already_booked', default: 'Je hebt deze sessie al geboekt.') if existing_booking
    raise BookingError, I18n.t('storefront.bookings.no_credits', default: 'Onvoldoende credits.') unless credits_available?

    Booking.transaction do
      booking = session.bookings.create!(user:, status: :confirmed)
      CreditLedger.create!(user:, gym: session.gym, booking:, amount: -1, reason: :booking_charge)
      booking
    end
  end

  def cancel!(booking:)
    raise BookingError, I18n.t('storefront.bookings.not_owner', default: 'Deze boeking is niet van jou.') if booking.user != user
    raise BookingError, I18n.t('storefront.bookings.already_canceled', default: 'Deze boeking is al geannuleerd.') if booking.status_canceled?
    raise BookingError, I18n.t('storefront.bookings.already_started', default: 'De sessie is al gestart.') if session.started?

    Booking.transaction do
      booking.update!(status: :canceled, canceled_at: Time.current)
      refund_if_eligible!(booking)
      booking
    end
  end

  private

  attr_reader :session, :user

  def existing_booking
    @existing_booking ||= session.bookings.find_by(user:, status: :confirmed)
  end

  def credits_available?
    CreditLedger.remaining_for(user:, gym: session.gym) > 0
  end

  def refund_if_eligible!(booking)
    return if session.cutoff_passed?

    CreditLedger.create!(user:, gym: session.gym, booking:, amount: 1, reason: :booking_refund)
  end
end
