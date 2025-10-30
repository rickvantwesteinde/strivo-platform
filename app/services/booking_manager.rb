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

    ensure_capacity!(from_waitlist)
    ensure_limits!(subscription, policy)

    booking = create_booking(subscription)
    BookingResult.new(booking: booking, waitlisted: false)
  end

  def cancel(booking:, canceled_at: Time.current, no_show: false)
    booking.transaction do
      if no_show
        booking.update!(no_show: true)
        return booking
      end

      booking.cancel!(canceled_at: canceled_at)
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

  def ensure_capacity!(from_waitlist)
    return if from_waitlist
    return if session.spots_left > 0
    waitlist_entry = WaitlistEntry.find_or_create_by!(session: session, user: user)
    raise CapacityError, BookingResult.new(waitlist_entry: waitlist_entry, waitlisted: true)
  end

  def ensure_limits!(subscription, policy)
    return if subscription.unlimited?
    balance = CreditLedger.balance_for(user: user, gym: session.gym)
    raise CreditError, "No credits" if balance <= 0

    daily = Booking.active_on_day(user, session.starts_at.to_date).count
    raise DailyLimitError if daily >= policy.max_active_daily_bookings
  end

  def create_booking(subscription)
    Booking.create!(
      gym: session.gym,
      user: user,
      session: session,
      subscription_plan: subscription.subscription_plan,
      status: :confirmed,
      used_credits: subscription.unlimited? ? 0 : 1
    )
  end

  def promote_from_waitlist
    entry = session.waitlist_entries.ordered.first or return
    entry.with_lock do
      result = self.class.new(user: entry.user, session: session).book(from_waitlist: true)
      entry.destroy!
      result
    end
  rescue CreditError, DailyLimitError
    entry.destroy!
    promote_from_waitlist
  end

  def existing_booking
    @existing_booking ||= session.bookings.status_confirmed.find_by(user: user)
  end
end
