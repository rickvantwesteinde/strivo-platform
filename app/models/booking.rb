# app/models/booking.rb
class Booking < ApplicationRecord
  belongs_to :gym
  belongs_to :user, class_name: 'Spree::User'
  belongs_to :session
  belongs_to :subscription_plan, optional: true

  has_many :credit_ledgers, dependent: :nullify

  enum :status, { confirmed: 0, canceled: 1 }, prefix: true

  validates :session_id, uniqueness: { scope: :user_id }
  validates :used_credits, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :sync_gym_and_plan

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

  def cancel!(canceled_at: Time.current)
    update!(status: :canceled, canceled_at: canceled_at)
  end

  private

  def sync_gym_and_plan
    self.gym ||= session.gym
    return if subscription_plan.present?

    sub = user.subscriptions.active.for_gym(gym).order(starts_on: :desc).first
    self.subscription_plan = sub&.subscription_plan
  end
end
