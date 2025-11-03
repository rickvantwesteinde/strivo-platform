class Booking < ApplicationRecord
<<<<<<< HEAD
  belongs_to :gym
  belongs_to :user, foreign_key: :user_id, class_name: 'Spree::User'
  belongs_to :session
  belongs_to :subscription_plan, optional: true

  enum :status, { confirmed: 0, canceled: 1 }, default: :confirmed
=======
  enum :status, { confirmed: 0, canceled: 1 }, prefix: true
>>>>>>> parent of 7c2f58f0 (feat(storefront): booking MVP (sessions list, book/cancel, my bookings) (#16))
end
