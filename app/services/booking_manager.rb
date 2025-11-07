# frozen_string_literal: true

class BookingManager
  class BookingError < StandardError; end

  def initialize(session:, user:, membership: nil)
    @session = session
    @user = user
    @provided_membership = membership
  end

  def book!
    # 1) Basischecks
    raise BookingError, I18n.t('storefront.bookings.full', default: 'Deze sessie is vol.') if session.full?
    raise BookingError, I18n.t('storefront.bookings.already_booked', default: 'Je hebt deze sessie al geboekt.') if existing_booking

    # 2) Logica:
    # - Unlimited membership -> alleen daily cap check (geen credits)
    # - Anders -> credits > 0 vereist (membership NIET verplicht)
    if relevant_membership&.unlimited?
      raise BookingError, I18n.t('storefront.bookings.daily_cap_reached', default: 'Dagelijkse limiet bereikt.') unless unlimited_plan_allows_booking?
    else
      raise BookingError, I18n.t('storefront.bookings.no_credits', default: 'Onvoldoende credits.') unless credits_available?
    end

    # 3) Boeken + ledger
    Booking.transaction do
      booking = session.bookings.create!(user:, status: :confirmed)
      record_booking_charge!(booking)
      booking
    end
  end

  # Laat zowel cancel!(booking) als cancel!(booking: booking) toe
  def cancel!(arg = nil, booking: nil)
    booking ||= arg

    raise BookingError, I18n.t('storefront.bookings.not_owner', default: 'Deze boeking is niet van jou.') if booking.user != user
    raise BookingError, I18n.t('storefront.bookings.already_canceled', default: 'Deze boeking is al geannuleerd.') if booking.status_canceled?
    raise BookingError, I18n.t('storefront.bookings.already_started', default: 'De sessie is al gestart.') if session.started?

    Booking.transaction do
      booking.update!(status: :canceled, canceled_at: Time.current)
      refund_if_eligible!(booking)
      booking
    end
  end

  def daily_cap_reached?
    membership = relevant_membership
    membership&.unlimited? && !unlimited_plan_allows_booking?
  end

  private

  attr_reader :session, :user, :provided_membership

  def relevant_membership
    @relevant_membership ||= begin
      if provided_membership&.gym_id == session.gym_id
        provided_membership
      else
        Membership
          .for_user_and_gym(user, session.gym)
          .where('starts_on <= ?', session.starts_at.to_date)
          .where('ends_on IS NULL OR ends_on >= ?', session.starts_at.to_date)
          .order(starts_on: :desc)
          .first
      end
    end
  end

  def existing_booking
    @existing_booking ||= session.bookings.find_by(user:, status: :confirmed)
  end

  def credits_available?
    CreditLedger.balance_for(user:, gym: session.gym) > 0
  end

  def unlimited_plan_allows_booking?
    membership = relevant_membership
    return false unless membership&.unlimited?

    cap = membership.daily_soft_cap.to_i
    return true if cap.zero?

    day_range = session.starts_at.beginning_of_day..session.starts_at.end_of_day

    Booking
      .joins(:session)
      .where(user:)
      .where(status: :confirmed)
      .where(sessions: { gym_id: session.gym_id })
      .where(sessions: { starts_at: day_range })
      .count < cap
  end

  # ✅ Altijd 1 credit afschrijven, behalve bij unlimited
  def record_booking_charge!(booking)
    return if relevant_membership&.unlimited? # unlimited gebruikt geen credits

    CreditLedger.create!(
      user: user,
      gym: session.gym,
      booking: booking,
      amount: -1,
      reason: :booking
    )
  end

  # ✅ Altijd 1 credit terug (tenzij cutoff gepasseerd of unlimited)
  def refund_if_eligible!(booking)
    return if session.cutoff_passed?
    return if relevant_membership&.unlimited? # unlimited werkte niet met credits

    CreditLedger.create!(
      user: user,
      gym: session.gym,
      booking: booking,
      amount: 1,
      reason: :refund
    )
  end
end