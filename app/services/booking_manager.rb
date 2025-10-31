# frozen_string_literal: true

class BookingManager
  class BookingError < StandardError; end

  def initialize(session:, user:)
    @session = session
    @user    = user
  end

  def book!
    raise BookingError, I18n.t('storefront.bookings.full',           default: 'Deze sessie is vol.')               if session_full?
    raise BookingError, I18n.t('storefront.bookings.already_booked', default: 'Je hebt deze sessie al geboekt.')   if existing_booking
    raise BookingError, I18n.t('storefront.bookings.no_credits',     default: 'Onvoldoende credits.')              unless credits_available?

    Booking.transaction do
      booking = Booking.create!(
        gym:,
        session:,
        user:,
        status: :confirmed,
        used_credits: 1
      )
      CreditLedger.create!(user:, gym:, booking:, amount: -1, reason: :booking_charge)
      booking
    end
  end

  # Laat zowel cancel!(booking) als cancel!(booking: booking) toe
  def cancel!(arg = nil, booking: nil)
    booking ||= arg

    raise BookingError, I18n.t('storefront.bookings.not_owner',        default: 'Deze boeking is niet van jou.')   if booking.user != user
    raise BookingError, I18n.t('storefront.bookings.already_canceled', default: 'Deze boeking is al geannuleerd.') if booking.canceled?
    raise BookingError, I18n.t('storefront.bookings.already_started',  default: 'De sessie is al gestart.')        if session_started?

    Booking.transaction do
      booking.update!(status: :canceled, canceled_at: Time.current)
      refund_if_eligible!(booking)
      booking
    end
  end

  private

  attr_reader :session, :user

  def session_class_type
  session.class_type
  end

  delegate :gym, to: :session_class_type

  def session_full?
    confirmed_bookings_count >= session.capacity
  end

  def confirmed_bookings_count
    Booking.where(session:, status: Booking.statuses[:confirmed]).count
  end

  def existing_booking
    @existing_booking ||= Booking.find_by(session:, user:, status: Booking.statuses[:confirmed])
  end

  def credits_available?
    CreditLedger.balance_for(user:, gym:) > 0
  end

  def refund_if_eligible!(booking)
    return if cutoff_passed?

    CreditLedger.create!(user:, gym:, booking:, amount: 1, reason: :booking_refund)
  end

  def cutoff_passed?
    Time.current > cutoff_time
  end

  def cutoff_time
    session.starts_at - cancellation_cutoff_hours.hours
  end

  def cancellation_cutoff_hours
    session.class_type.default_cancellation_cutoff_hours || gym.cancel_cutoff_hours
  end

  def session_started?
    Time.current >= session.starts_at
  end
end
