class Session < ApplicationRecord
  belongs_to :class_type
  belongs_to :trainer

  # Haal gym via de class_type (geen gym_id kolom op sessions)
  delegate :gym, to: :class_type

  validates :starts_at, presence: true
end