# app/models/gym.rb
class Gym < ApplicationRecord
  # Associations uit beide kanten samengevoegd
  has_many :class_types,        dependent: :destroy
  has_many :sessions,           dependent: :destroy   # direct association (main)
  has_many :credit_ledgers,     dependent: :destroy
  has_many :trainers,           dependent: :destroy
  has_many :subscription_plans, dependent: :destroy
  has_many :subscriptions,      dependent: :destroy
  has_one  :policy,             dependent: :destroy

  # Validations
  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  # Helpers
  def to_s
    name
  end
end