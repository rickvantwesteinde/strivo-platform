class ClassType < ApplicationRecord
  belongs_to :gym
  has_many :sessions, dependent: :destroy

  validates :name, presence: true

  def upcoming_sessions(limit: 5, until_time: 2.weeks.from_now)
    sessions.upcoming(until_time:).limit(limit)
  end
end
