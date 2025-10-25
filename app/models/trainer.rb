class Trainer < ApplicationRecord
  belongs_to :gym
  belongs_to :user, class_name: "Spree::User"
  has_many :sessions, dependent: :nullify

  validates :user_id, uniqueness: { scope: :gym_id }
end
