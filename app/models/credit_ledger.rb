# frozen_string_literal: true

class CreditLedger < ApplicationRecord
  belongs_to :user, class_name: "Spree::User"
  belongs_to :gym

  # Rails 7.1/8 enum-signature
  enum :reason, {
    manual_grant: 0,
    purchase:     1,
    refund:       2,
    booking:      3,
    adjustment:   4
  }

  validates :amount, presence: true, numericality: { other_than: 0 }
  validates :reason, presence: true

  # Gebruik geen 'for' als scopenaam (Ruby keyword)
  scope :by_user_gym, ->(user:, gym:) { where(user:, gym:) }

  def self.balance_for(user:, gym:)
    by_user_gym(user:, gym:).sum(:amount)
  end
end