# frozen_string_literal: true

class Gym < ApplicationRecord
  has_many :policies, dependent: :destroy
  has_many :class_types, dependent: :destroy
  has_many :trainers, dependent: :destroy
  has_many :subscription_plans, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :credit_ledgers, dependent: :destroy
  has_many :sessions, through: :class_types

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  def policy
    policies.first_or_create!(
      cancel_cutoff_hours: 6,
      rollover_limit: 2,
      max_active_daily_bookings: 1
    )
  end

  def to_s
    name
  end
end
