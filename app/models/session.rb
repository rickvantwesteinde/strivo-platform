# app/models/session.rb
class Session < ApplicationRecord
  # Associations
  belongs_to :class_type
  belongs_to :trainer

  has_many :bookings, dependent: :destroy
  has_many :waitlist_entries, dependent: :destroy

  # Delegate gym via class_type
  delegate :gym, to: :class_type

  # Validations
  validates :starts_at, :duration_minutes, presence: true
  validates :capacity, numericality: { greater_than: 0 }

  # Callbacks
  before_validation :apply_default_capacity

  # Scopes
  scope :upcoming, ->(until_time: 2.weeks.from_now) {
    where(starts_at: Time.current..until_time).order(:starts_at)
  }

  # Helpers
  def ends_at
    starts_at + duration_minutes.minutes
  end

  def confirmed_bookings
    bookings.status_confirmed
  end

  def spots_taken
    confirmed_bookings.count
  end

  def spots_left
    [capacity - spots_taken, 0].max
  end

  def full?
    spots_left.zero?
  end

  def cutoff_time
    starts_at - cancellation_cutoff_hours.hours
  end

  def cutoff_passed?
    Time.current > cutoff_time
  end

  def started?
    Time.current >= starts_at
  end

  def spots_remaining
    spots_left
  end

  private

  def apply_default_capacity
    self.capacity ||= class_type&.default_capacity
  end
end
