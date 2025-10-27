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

  # Scopes
  scope :active_on_day, ->(user, date) {
    status_confirmed
      .where(user: user)
      .joins(:session)
      .where(sessions: { starts_at: date.beginning_of_day..date.end_of_day })
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

  private

  def sync_gym_and_plan
    # denormalized gym for fast queries; keep in sync with the session's gym
    self.gym ||= session&.gym

    # pick the user's current subscription plan for this gym (if aanwezig)
    if self.subscription_plan.blank? && session && user
      current_sub = user.subscriptions.respond_to?(:current) ? user.subscriptions.current : user.subscriptions
      self.subscription_plan ||= current_sub.respond_to?(:for_gym) ? current_sub.for_gym(session.gym).first&.plan : current_sub.first&.plan
    end
  end
end