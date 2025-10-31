class ClassType < ApplicationRecord
  belongs_to :gym
  has_many :sessions, dependent: :destroy

  validates :name, presence: true

  def upcoming_sessions(limit: 5, until_time: 2.weeks.from_now)
    Session.where(class_type: self, starts_at: Time.current..until_time).order(:starts_at).limit(limit)
  end
end
