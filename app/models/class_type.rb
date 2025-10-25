class ClassType < ApplicationRecord
  belongs_to :gym
  has_many :sessions, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :gym_id }

  def capacity
    default_capacity
  end
end
