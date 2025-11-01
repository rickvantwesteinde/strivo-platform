# app/models/session.rb
class Session < ApplicationRecord
  belongs_to :gym
  belongs_to :class_type
  belongs_to :trainer

  # (optioneel) validaties
  validates :starts_at, presence: true
end