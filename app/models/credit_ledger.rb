class CreditLedger < ApplicationRecord
  belongs_to :user, class_name: 'Spree::User'
  belongs_to :gym
  belongs_to :booking, optional: true

  enum :reason,
       {
         monthly_grant: 0,
         booking_charge: 1,
         booking_refund: 2,
         rollover_expiry: 3,
         manual_adjustment: 4
       },
       prefix: true

  validates :amount, presence: true

  scope :for_user_and_gym, ->(user, gym) { where(user:, gym:) }

  def self.remaining_for(user:, gym:)
    for_user_and_gym(user, gym).sum(:amount)
  end
end
