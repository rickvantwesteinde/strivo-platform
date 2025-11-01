
# frozen_string_literal: true

class ClassType < ApplicationRecord
  belongs_to :gym
  has_many :sessions, dependent: :destroy

  validates :name, presence: true
  validates :default_capacity, numericality: { greater_than: 0 }, allow_nil: true
end