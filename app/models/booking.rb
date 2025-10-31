class Booking < ApplicationRecord
  belongs_to :gym
  belongs_to :user, foreign_key: :user_id, class_name: 'Spree::User'
  belongs_to :session
  belongs_to :subscription_plan, optional: true

  enum :status, { confirmed: 0, canceled: 1 }, default: :confirmed
end
