class Gym < ApplicationRecord
  has_many :class_types, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :credit_ledgers, dependent: :destroy

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  def to_s
    name
  end
end
