# frozen_string_literal: true

module Reports
  class BasicUtilization
    Row = Struct.new(
      :session_id,
      :starts_at,
      :class_type_name,
      :capacity,
      :confirmed_bookings,
      :fill_rate,
      keyword_init: true
    )

    def initialize(gym:, start_on:, end_on:)
      @gym = gym
      @start_on = start_on
      @end_on = end_on
    end

    def call
      return [] if gym.nil?

      sessions = Session
                  .includes(:class_type)
                  .where(gym:)
                  .where(starts_at: range)
                  .order(:starts_at)

      counts = Booking.status_confirmed.where(session: sessions).group(:session_id).count

      sessions.map do |session|
        confirmed = counts[session.id] || 0
        capacity = session.capacity
        fill_rate = capacity.positive? ? confirmed.to_f / capacity : 0.0

        Row.new(
          session_id: session.id,
          starts_at: session.starts_at,
          class_type_name: session.class_type.name,
          capacity:,
          confirmed_bookings: confirmed,
          fill_rate: fill_rate
        )
      end
    end

    private

    attr_reader :gym, :start_on, :end_on

    def range
      start_on.beginning_of_day..end_on.end_of_day
    end
  end
end
