# app/models/class_type.rb
class ClassType < ApplicationRecord
  belongs_to :gym
  has_many :sessions, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :gym_id }

  # Optioneel: als je een kolom default_capacity hebt in je migratie
  def capacity
    default_capacity
  end

  # Handige helper om komende sessies te tonen
  def upcoming_sessions(limit: 5, until_time: 2.weeks.from_now)
    sessions.upcoming(until_time:).limit(limit)
  end
end