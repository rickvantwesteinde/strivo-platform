class Policy < ApplicationRecord
  belongs_to :gym

  validates :cancel_cutoff_hours, :rollover_limit, :max_active_daily_bookings, presence: true
end