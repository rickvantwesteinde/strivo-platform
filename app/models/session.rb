# frozen_string_literal: true

class Session < ApplicationRecord
  belongs_to :class_type
  belongs_to :gym
  belongs_to :trainer

  # Keep gym consistent with the class_type's gym if not set explicitly.
  before_validation :sync_gym_from_class_type, if: -> { class_type.present? && gym_id.blank? }

  validates :starts_at, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }
  validates :capacity, numericality: { greater_than_or_equal_to: 1 }

  validate :trainer_in_same_gym
  validate :class_type_in_same_gym

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }

  private

  def sync_gym_from_class_type
    self.gym_id = class_type.gym_id
  end

  def trainer_in_same_gym
    return if trainer.blank? || gym_id.blank?
    errors.add(:trainer_id, "must belong to the same gym") if trainer.gym_id != gym_id
  end

  def class_type_in_same_gym
    return if class_type.blank? || gym_id.blank?
    errors.add(:class_type_id, "must belong to the same gym") if class_type.gym_id != gym_id
  end
end
