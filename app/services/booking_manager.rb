# app/services/booking_manager.rb
class BookingManager
  BookingResult = Struct.new(:booking, :waitlist_entry, :waitlisted, keyword_init: true)

  # Domein-specifieke fouten
  class Error < StandardError; end
  class SubscriptionRequiredError < Error; end
  class CreditError < Error; end
  class CapacityError < Error; end
  class DailyLimitError < Error; end

  def initialize(user:, session:)
    @user = user
    @session = session
  end

  # Boek een sessie. Zet op waitlist als vol (tenzij from_waitlist).
  def book(from_waitlist: false)
    # Dubbelboeking voorkomen (snelle guard)
    if existing_booking
      return BookingResult.new(booking: existing_booking, waitlisted: false)
    end

    subscription = find_subscription!
    policy = session.gym.policy or raise Error, "Policy missing for gym"

    if subscription.unlimited?
      ensure_daily_limit!(policy)
    else
      ensure_credits_available!
    end

    # Indien vol en niet vanaf waitlist → naar wachtlijst
    if session.spots_remaining <= 0 && !from_waitlist
      waitlist_entry = WaitlistEntry.find_or_create_by!(session: session, user: user)
      return BookingResult.new(waitlist_entry: waitlist_entry, waitlisted: true)
    end

    raise CapacityError, "Session full" if session.spots_remaining <= 0

    booking = create_booking(subscription)
    BookingResult.new(booking: booking, waitlisted: false)
  end

  # Annuleer of markeer als no-show.
  # Codex-fix: bij no_show géén waitlist-promotie (er komt geen plek vrij).
  def cancel(booking:, canceled_at: Time.current, no_show: false)
    booking.transaction do
      if no_show
        booking.update!(no_show: true)
        return booking # <<< Belangrijk: STOP, niet promoten
      else
        booking.cancel!(canceled_at: canceled_at)
      end

      policy = booking.gym.policy or raise Error, "Policy missing for gym"
      maybe_refund!(booking: booking, canceled_at: canceled_at, policy: policy)

      promote_from_waitlist
    end
  end

  private

  attr_reader :user, :session

  # Huidige (geldige) subscription voor de gym vinden
  def find_subscription!
    scope = user.subscriptions
    scope = scope.current if scope.respond_to?(:current)
    scope = scope.for_gym(session.gym) if scope.respond_to?(:for_gym)

    subscription = scope.order(starts_on: :desc).first
    raise SubscriptionRequiredError, "Active subscription required" unless subscription

    subscription
  end

  # Non-unlimited: check credits
  def ensure_credits_available!
    balance = CreditLedger.balance_for(user: user, gym: session.gym)
    raise CreditError, "Insufficient credits" if balance <= 0
  end

  # Unlimited: max actieve boekingen per dag
  def ensure_daily_limit!(policy)
    daily_bookings = Booking.active_on_day(user, session.starts_at.to_date).where(gym: session.gym)
    if daily_bookings.count >= policy.max_active_daily_bookings
      raise DailyLimitError, "Daily limit reached"
    end
  end

  # Boek aanmaken + creditcharge registreren
  def create_booking(subscription)
    used_credits = subscription.unlimited? ? 0 : 1

    booking = Booking.create!(
      gym: session.gym,
      user: user,
      session: session,
      subscription_plan: subscription.plan,
      status: :confirmed,
      used_credits: used_credits
    )

    log_booking_charge(booking: booking, subscription: subscription)
    booking
  end

  # Ledger entry voor charge (of 0 bij unlimited)
  def log_booking_charge(booking:, subscription:)
    amount = subscription.unlimited? ? 0 : -booking.used_credits

    CreditLedger.create!(
      gym: booking.gym,
      user: booking.user,
      booking: booking,
      amount: amount,
      reason: :booking_charge,
      metadata: {
        session_id: booking.session_id,
        subscription_plan_id: subscription.plan_id,
        unlimited: subscription.unlimited?
      }
    )
  end

  # Refund alleen als vóór cutoff en niet-unlimited
  def maybe_refund!(booking:, canceled_at:, policy:)
    return if booking.subscription_plan&.unlimited?

    cutoff_hours = policy.respond_to?(:cancel_cutoff_hours) ? (policy.cancel_cutoff_hours || 0) : 0
    cutoff_time = booking.session.starts_at - cutoff_hours.hours
    return unless canceled_at < cutoff_time

    CreditLedger.create!(
      gym: booking.gym,
      user: booking.user,
      booking: booking,
      amount: booking.used_credits,
      reason: :booking_refund,
      metadata: { session_id: booking.session_id }
    )
  end

  # Waitlist promotie (alleen aanroepen wanneer er daadwerkelijk plek vrij is)
  def promote_from_waitlist
    entry = session.waitlist_entries.ordered.first
    return unless entry

    entry.with_lock do
      result = self.class.new(user: entry.user, session: session).book(from_waitlist: true)
      entry.destroy!
      result
    rescue CreditError, DailyLimitError, SubscriptionRequiredError
      # kan niet promoten → verwijder en probeer volgende
      entry.destroy!
      promote_from_waitlist
    end
  end

  # Bestaat er al een confirmed booking voor deze user in deze sessie?
  def existing_booking
    @existing_booking ||= session.bookings.status_confirmed.find_by(user: user)
  end
end