# frozen_string_literal: true

class Trainer < ApplicationRecord
  belongs_to :gym
  belongs_to :user, class_name: "Spree::User"

  has_many :sessions, dependent: :nullify

  validates :gym, :user, presence: true
  validates :user_id, uniqueness: { scope: :gym_id }
end