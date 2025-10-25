class BookingManager
  BookingResult = Struct.new(:booking, :waitlist_entry, :waitlisted, keyword_init: true)

  class Error < StandardError; end
  class SubscriptionRequiredError < Error; end
  class CreditError < Error; end
  class CapacityError < Error; end
  class DailyLimitError < Error; end

  def initialize(user:, session:)
    @user = user
    @session = session
  end

  def book(from_waitlist: false)
    subscription = find_subscription!
    policy = session.gym.policy or raise Error, "Policy missing for gym"

    if subscription.unlimited?
      ensure_daily_limit!(policy)
    else
      ensure_credits_available!
    end

    if session.spots_remaining <= 0 && !from_waitlist
      waitlist_entry = WaitlistEntry.find_or_create_by!(session:, user:)
      return BookingResult.new(waitlist_entry:, waitlisted: true)
    end

    raise CapacityError, "Session full" if session.spots_remaining <= 0

    booking = create_booking(subscription)

    BookingResult.new(booking:, waitlisted: false)
  end

  def cancel(booking:, canceled_at: Time.current, no_show: false)
    booking.transaction do
      if no_show
        booking.update!(no_show: true)
      else
        booking.cancel!(canceled_at:)
      end

      policy = booking.gym.policy or raise Error, "Policy missing for gym"

      maybe_refund!(booking:, canceled_at:, policy:) unless no_show

      promote_from_waitlist
    end
  end

  private

  attr_reader :user, :session

  def find_subscription!
    subscription = user.subscriptions.current.for_gym(session.gym).order(starts_on: :desc).first
    raise SubscriptionRequiredError, "Active subscription required" unless subscription

    subscription
  end

  def ensure_credits_available!
    balance = CreditLedger.balance_for(user:, gym: session.gym)
    raise CreditError, "Insufficient credits" if balance <= 0
  end

  def ensure_daily_limit!(policy)
    daily_bookings = Booking.active_on_day(user, session.starts_at.to_date).where(gym: session.gym)
    if daily_bookings.count >= policy.max_active_daily_bookings
      raise DailyLimitError, "Daily limit reached"
    end
  end

  def create_booking(subscription)
    used_credits = subscription.unlimited? ? 0 : 1

    booking = Booking.create!(
      gym: session.gym,
      user:,
      session:,
      subscription_plan: subscription.plan,
      status: :confirmed,
      used_credits:
    )

    log_booking_charge(booking:, subscription:)

    booking
  end

  def log_booking_charge(booking:, subscription:)
    amount = subscription.unlimited? ? 0 : -booking.used_credits

    CreditLedger.create!(
      gym: booking.gym,
      user: booking.user,
      booking:,
      amount:,
      reason: :booking_charge,
      metadata: {
        session_id: booking.session_id,
        subscription_plan_id: subscription.plan_id,
        unlimited: subscription.unlimited?
      }
    )
  end

  def maybe_refund!(booking:, canceled_at:, policy:)
    return if booking.subscription_plan.unlimited?

    cutoff_time = booking.session.starts_at - (policy.cancel_cutoff_hours || 0).hours
    return unless canceled_at < cutoff_time

    CreditLedger.create!(
      gym: booking.gym,
      user: booking.user,
      booking:,
      amount: booking.used_credits,
      reason: :booking_refund,
      metadata: { session_id: booking.session_id }
    )
  end

  def promote_from_waitlist
    entry = session.waitlist_entries.ordered.first
    return unless entry

    entry.with_lock do
      result = self.class.new(user: entry.user, session: session).book(from_waitlist: true)
      entry.destroy!
      result
    rescue CreditError, DailyLimitError, SubscriptionRequiredError
      entry.destroy!
      promote_from_waitlist
    end
  end
end
