# frozen_string_literal: true

class Session < ApplicationRecord
  belongs_to :gym
  belongs_to :class_type
  belongs_to :trainer

  has_many :bookings, dependent: :destroy
  has_many :waitlist_entries, dependent: :destroy

  validates :starts_at, :duration_minutes, :capacity, presence: true

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  scope :for_gym,  ->(gym) { where(gym_id: gym) }
end