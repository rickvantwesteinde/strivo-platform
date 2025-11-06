class CreditLedger < ApplicationRecord
  belongs_to :user, class_name: "Spree::User"
  belongs_to :gym

  # Gebruik de nieuwe enum signature in Rails 7.1/8:
  enum :reason, {
    manual_grant: 0,
    purchase:     1,
    refund:       2,
    booking:      3,
    adjustment:   4
  }

  validates :amount, presence: true, numericality: { other_than: 0 }
  validates :reason, presence: true

  # Niet for gebruiken (Ruby keyword) --> alternatieve naam
  scope :by_user_gym, ->(user:, gym:) { where(user:, gym:) }

  def self.balance_for(user:, gym:)
    by_user_gym(user:, gym:).sum(:amount)
  end
end
