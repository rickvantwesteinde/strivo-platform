# app/services/booking_manager.rb
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
    return BookingResult.new(booking: existing_booking, waitlisted: false) if existing_booking

    subscription = find_subscription!
    policy = session.gym.policy || raise(Error, "Policy missing")

    if subscription.unlimited?
      ensure_daily_limit!(policy)
    else
      ensure_credits_available!
    end

    if session.spots_left <= 0 && !from_waitlist
      waitlist_entry = WaitlistEntry.find_or_create_by!(session: session, user: user)
      return BookingResult.new(waitlist_entry: waitlist_entry, waitlisted: true)
    end

    raise CapacityError, "Session full" if session.spots_left <= 0

    booking = create_booking(subscription)
    BookingResult.new(booking: booking, waitlisted: false)
  end

  def cancel(booking:, canceled_at: Time.current, no_show: false)
    booking.transaction do
      if no_show
        booking.update!(no_show: true)
        return booking
      else
        booking.cancel!(canceled_at: canceled_at)
      end

      policy = booking.gym.policy || raise(Error, "Policy missing")
      maybe_refund!(booking: booking, canceled_at: canceled_at)

      promote_from_waitlist if booking.session.spots_left > 0
    end
  end

  private

  attr_reader :user, :session

  def find_subscription!
    scope = user.subscriptions.active
    scope = scope.for_gym(session.gym) if scope.respond_to?(:for_gym)
    scope.order(:starts_on).last || raise(SubscriptionRequiredError)
  end

  def ensure_credits_available!
    balance = CreditLedger.balance_for(user: user, gym: session.gym)
    raise CreditError, "Insufficient credits" if balance <= 0
  end

  def ensure_daily_limit!(policy)
    daily = Booking.active_on_day(user, session.starts_at.to_date).count
    raise DailyLimitError if daily >= policy.max_active_daily_bookings
  end

  def create_booking(subscription)
    used_credits = subscription.unlimited? ? 0 : 1

    booking = Booking.create!(
      gym: session.gym,
      user: user,
      session: session,
      subscription_plan: subscription.subscription_plan,
      status: :confirmed,
      used_credits: used_credits
    )

    log_booking_charge(booking: booking, subscription: subscription)
    booking
  end

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
        subscription_plan_id: subscription.subscription_plan_id,
        unlimited: subscription.unlimited?
      }
    )
  end

  def maybe_refund!(booking:, canceled_at:)
    return if booking.subscription_plan&.unlimited?

    return unless canceled_at < booking.session.cutoff_time

    CreditLedger.create!(
      gym: booking.gym,
      user: booking.user,
      booking: booking,
      amount: booking.used_credits,
      reason: :booking_refund,
      metadata: { session_id: booking.session_id, canceled_at: canceled_at }
    )
  end

  def promote_from_waitlist
    entry = session.waitlist_entries.ordered.first or return
    entry.with_lock do
      result = self.class.new(user: entry.user, session: session).book(from_waitlist: true)
      entry.destroy!
      result
    end
  rescue CreditError, DailyLimitError, SubscriptionRequiredError
    entry.destroy!
    promote_from_waitlist
  end

  def existing_booking
    @existing_booking ||= session.bookings.status_confirmed.find_by(user: user)
  end
end
