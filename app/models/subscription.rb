# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :gym
  belongs_to :user, class_name: 'Spree::User'
  belongs_to :subscription_plan

  enum :status, { active: 0, paused: 1, canceled: 2 }, prefix: true

  validates :starts_on, presence: true

  before_validation :sync_gym

  scope :for_gym, ->(gym) { where(gym: gym) }
  scope :for_user, ->(user) { where(user: user) }
  scope :current, -> do
    status_active
      .where('starts_on <= ?', Date.current)
      .where('ended_at IS NULL OR ended_at >= ?', Date.current)
  end

  after_commit :grant_initial_credits, on: :create

  def active_on?(date)
    status_active? && starts_on <= date && (ended_at.nil? || ended_at >= date)
  end

  def unlimited?
    subscription_plan.unlimited?
  end

  # Alias for compatibility with code that uses 'plan'
  alias_method :plan, :subscription_plan

  private

  def sync_gym
    self.gym ||= subscription_plan.gym if subscription_plan
  end

  def grant_initial_credits
    return unless active_on?(Date.current)

    MonthlyCreditGrant.new(subscription: self, as_of: Date.current).call
  end
end
