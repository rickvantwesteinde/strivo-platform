class Session < ApplicationRecord
  belongs_to :class_type
  belongs_to :trainer

  has_many :bookings, dependent: :destroy
  has_many :waitlist_entries, dependent: :destroy

  delegate :gym, to: :class_type

  validates :starts_at, :duration_minutes, presence: true

  before_validation :apply_default_capacity

  scope :upcoming, -> { where("starts_at >= ?", Time.current) }

  def ends_at
    starts_at + duration_minutes.minutes
  end

  def confirmed_bookings
    bookings.confirmed
  end

  def spots_remaining
    capacity - confirmed_bookings.count
  end

  private

  def apply_default_capacity
    self.capacity ||= class_type&.capacity
  end
end
