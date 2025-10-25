# app/models/booking.rb
class Booking < ApplicationRecord
  belongs_to :gym
  belongs_to :user, class_name: "Spree::User"
  belongs_to :session
  belongs_to :subscription_plan

  # Rails 8 enum signature:
  enum :status, { confirmed: 0, canceled: 1 }, prefix: true

  validates :session_id, uniqueness: { scope: :user_id }
  validates :used_credits, numericality: { greater_than_or_equal_to: 0 }

  before_validation :sync_gym_and_plan

  scope :active_on_day, ->(user, date) {
    status_confirmed
      .where(user:)
      .joins(:session)
      .where(sessions: { starts_at: date.beginning_of_day..date.end_of_day })
  }

  def cancel!(canceled_at: Time.current)
    update!(status: :canceled, canceled_at:)
  end

  private

  def sync_gym_and_plan
    self.gym ||= session&.gym
    self.subscription_plan ||= session && user && user.subscriptions.current.for_gym(session.gym).first&.plan
  end
end
