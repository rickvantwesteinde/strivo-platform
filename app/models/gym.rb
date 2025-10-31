# app/models/gym.rb
class Gym < ApplicationRecord
  has_many :policies
  has_many :class_types
  has_many :trainers
  has_many :subscription_plans
  has_many :subscriptions
  has_many :bookings
  has_many :credit_ledgers

  # Optional: delegate policy defaults
  delegate :cancel_cutoff_hours, :rollover_limit, :max_active_daily_bookings, to: :default_policy

  def default_policy
    policies.first_or_create!(
      cancel_cutoff_hours: 6,
      rollover_limit: 2,
      max_active_daily_bookings: 1
    )
  end
end