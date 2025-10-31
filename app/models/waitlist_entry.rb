# frozen_string_literal: true

class WaitlistEntry < ApplicationRecord
  belongs_to :session
  belongs_to :user, class_name: 'Spree::User'

  validates :position, presence: true
  validates :user_id, uniqueness: { scope: :session_id }

  before_validation :assign_position, on: :create

  scope :ordered, -> { order(:position, :created_at) }

  private

  def assign_position
    return if position.present?

    self.position = session.waitlist_entries.maximum(:position).to_i + 1
  end
end
