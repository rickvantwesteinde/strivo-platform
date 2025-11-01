# frozen_string_literal: true

class CreditLedger < ApplicationRecord
  belongs_to :gym
  belongs_to :user, class_name: "Spree::User"
  belongs_to :booking, optional: true

  enum :reason, {
    manual_grant: 0,
    monthly_grant: 1,
    booking_charge: 2,
    booking_refund: 3
  }

  validates :amount, presence: true, numericality: { only_integer: true }

  scope :for_user_and_gym, ->(user:, gym:) { where(user:, gym:) }
end
