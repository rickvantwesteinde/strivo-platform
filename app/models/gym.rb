class Gym < ApplicationRecord
  has_many :class_types, dependent: :destroy
  has_many :trainers, dependent: :destroy
  has_many :subscription_plans, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_one :policy, dependent: :destroy
  has_many :sessions, through: :class_types

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
end
