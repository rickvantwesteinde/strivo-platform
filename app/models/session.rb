class Session < ApplicationRecord
  belongs_to :class_type
  belongs_to :trainer

  has_many :bookings, dependent: :destroy
  has_many :waitlist_entries, dependent: :destroy

  delegate :gym, to: :class_type

  validates :starts_at, :duration_minutes, presence: true
  validates :capacity, numericality: { greater_than: 0 }

  before_validation :apply_default_capacity

  scope :upcoming, ->(until_time: 2.weeks.from_now) {
    where(starts_at: Time.current..until_time).order(:starts_at)
  }

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
    starts_at - (gym.policy&.cancel_cutoff_hours || 6).hours
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