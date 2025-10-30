# app/models/booking.rb
class Booking < ApplicationRecord
  # Associations
  belongs_to :gym
  belongs_to :user, class_name: 'Spree::User'
  belongs_to :session
  belongs_to :subscription_plan, optional: true

  has_many :credit_ledgers, dependent: :nullify

  # Status
  enum :status, { confirmed: 0, canceled: 1 }, prefix: true

  # Validations
  validates :session_id, uniqueness: { scope: :user_id }
  validates :used_credits, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Callbacks
  before_validation :sync_gym_and_plan
  after_create :consume_credits, unless: :unlimited?
  after_update :refund_credits, if: :canceled_before_cutoff?

  # Scopes
  scope :active_on_day, ->(user, date) {
    status_confirmed
      .where(user: user)
      .joins(:session)
      .where('sessions.starts_at BETWEEN ? AND ?', date.beginning_of_day, date.end_of_day)
  }

  scope :upcoming, -> {
    joins(:session)
      .where('sessions.starts_at >= ?', Time.current)
      .order('sessions.starts_at ASC')
  }

  scope :past, -> {
    joins(:session)
      .where('sessions.starts_at < ?', Time.current)
      .order('sessions.starts_at DESC')
  }

  # Commands
  def cancel!(canceled_at: Time.current)
    update!(status: :canceled, canceled_at: canceled_at)
  end

  def unlimited?
    subscription_plan&.unlimited?
  end

  private

  def sync_gym_and_plan
    self.gym ||= session.gym
    return if subscription_plan.present?

    current_sub = user.subscriptions.active.for_gym(gym).first
    self.subscription_plan = current_sub&.subscription_plan
  end

  def consume_credits
    return if unlimited?
    CreditLedger.create!(
      gym: gym,
      user: user,
      booking: self,
      reason: :booking_charge,
      amount: -1,
      metadata: { session_id: session_id }
    )
    update_column(:used_credits, 1)
  end

  def refund_credits
    return if unlimited?
    CreditLedger.create!(
      gym: gym,
      user: user,
      booking: self,
      reason: :booking_refund,
      amount: 1,
      metadata: { session_id: session_id, canceled_at: canceled_at }
    )
  end

  def canceled_before_cutoff?
    saved_change_to_status? &&
      status_canceled? &&
      canceled_at < session.cutoff_time
  end
end
