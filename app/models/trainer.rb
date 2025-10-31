class Trainer < ApplicationRecord
  belongs_to :gym
  belongs_to :user, foreign_key: :user_id, class_name: 'Spree::User'
  has_many :sessions, dependent: :destroy
end
