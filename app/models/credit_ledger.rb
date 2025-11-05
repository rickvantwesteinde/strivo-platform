class CreditLedger < ApplicationRecord
  belongs_to :user, class_name: "Spree::User"
  belongs_to :gym

  enum reason: {
    manual_grant: 0,
    purchase:     1,
    refund:       2,
    booking:      3,
    adjustment:   4
  }

  validates :amount, presence: true, numericality: { other_than: 0 }
  validates :reason, presence: true

  scope :for, ->(user:, gym:) { where(user:, gym:) }

  def self.balance_for(user:, gym:)
    for(user:, gym:).sum(:amount)
  end
end
