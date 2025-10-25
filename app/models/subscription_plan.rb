class SubscriptionPlan < ApplicationRecord
  belongs_to :gym
  has_many :subscriptions, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :name, uniqueness: { scope: :gym_id }
  validates :per_week, numericality: { greater_than_or_equal_to: 0 }

  scope :unlimited, -> { where(unlimited: true) }
end
