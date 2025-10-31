# frozen_string_literal: true

class ClassType < ApplicationRecord
  belongs_to :gym
  has_many :sessions, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :gym_id }

  def capacity
    default_capacity
  end

  def upcoming_sessions(limit: 5, until_time: 2.weeks.from_now)
    sessions.upcoming(until_time: until_time).limit(limit)
  end
end
