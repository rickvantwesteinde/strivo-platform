class Subscription < ApplicationRecord
  belongs_to :gym
  belongs_to :user, class_name: "Spree::User"
  belongs_to :plan, class_name: "SubscriptionPlan", foreign_key: :subscription_plan_id

  enum :status, %i[active paused canceled]

  validates :starts_on, presence: true

  before_validation :sync_gym

  scope :for_gym, ->(gym) { where(gym:) }
  scope :for_user, ->(user) { where(user:) }
  scope :current, -> { active.where("starts_on <= ?", Date.current).where("ended_at IS NULL OR ended_at >= ?", Date.current) }

  after_commit :grant_initial_credits, on: :create

  def active_on?(date)
    active? && starts_on <= date && (ended_at.nil? || ended_at >= date)
  end

  def unlimited?
    plan.unlimited?
  end

  private

  def sync_gym
    self.gym ||= plan.gym if plan
  end

  def grant_initial_credits
    return unless active_on?(Date.current)

    MonthlyCreditGrant.new(subscription: self, as_of: Date.current).call
  end
end
