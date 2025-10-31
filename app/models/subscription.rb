class Subscription < ApplicationRecord
  belongs_to :gym
  belongs_to :user, foreign_key: :user_id, class_name: 'Spree::User'
  belongs_to :subscription_plan
end
