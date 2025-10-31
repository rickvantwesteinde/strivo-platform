class SubscriptionPlan < ApplicationRecord
  belongs_to :gym
  has_many :subscriptions, dependent: :destroy
  has_many :bookings, dependent: :nullify
end
