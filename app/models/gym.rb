# frozen_string_literal: true

class Gym < ApplicationRecord
  has_many :class_types,  dependent: :destroy
  has_many :trainers,     dependent: :destroy
  has_many :sessions,     dependent: :destroy
  has_many :bookings,     dependent: :destroy
  has_many :credit_ledgers, dependent: :destroy
  has_many :subscription_plans, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  # Dummy policy helper (laat zoals je ‘m had als er al implementatie is)
  def default_policy
    policies.first || policies.create!
  end

  has_many :policies, dependent: :destroy
end