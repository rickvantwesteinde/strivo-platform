# frozen_string_literal: true

class ClassType < ApplicationRecord
  belongs_to :gym
  has_many :sessions, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :default_capacity, numericality: { greater_than_or_equal_to: 1 }
  validates :default_duration_minutes, numericality: { greater_than: 0 }, allow_nil: true
  validates :default_cancellation_cutoff_hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
