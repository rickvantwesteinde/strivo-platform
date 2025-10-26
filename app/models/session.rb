class Session < ApplicationRecord
  belongs_to :class_type
  belongs_to :gym

  has_many :bookings, dependent: :destroy

  validates :starts_at, presence: true
  validates :capacity, numericality: { greater_than: 0 }
  validate :gym_matches_class_type

  scope :upcoming, ->(until_time: 2.weeks.from_now) { where(starts_at: Time.current..until_time).order(:starts_at) }

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

  private

  def gym_matches_class_type
    return if class_type.nil? || gym_id == class_type.gym_id

    errors.add(:gym_id, 'must match class type gym')
  end
end
