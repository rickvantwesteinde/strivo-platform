class CreditLedger < ApplicationRecord
<<<<<<< HEAD
  belongs_to :gym
  belongs_to :user, foreign_key: :user_id, class_name: 'Spree::User'
  belongs_to :booking, optional: true

  enum :reason, {
    monthly_grant: 0,
    booking_charge: 1,
    booking_refund: 2,
    rollover_expiry: 3
  }

  scope :for_user_and_gym, ->(user:, gym:) { where(user: user, gym: gym) }

  def self.balance_for(user:, gym:)
    for_user_and_gym(user: user, gym: gym).sum(:amount)
  end
=======
  enum :reason,
       {
         monthly_grant: 0,
         booking_charge: 1,
         booking_refund: 2,
         rollover_expiry: 3,
         manual_adjustment: 4
       },
       prefix: true
>>>>>>> parent of 7c2f58f0 (feat(storefront): booking MVP (sessions list, book/cancel, my bookings) (#16))
end
