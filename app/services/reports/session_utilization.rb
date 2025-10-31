# frozen_string_literal: true

module Reports
  class SessionUtilization
    def initialize(session)
      @session = session
    end

    def call
      {
        session_id: session.id,
        bookings_count: session.bookings.status_confirmed.count,
        capacity: session.capacity,
        no_shows_count: session.bookings.status_confirmed.where(no_show: true).count
      }
    end

    private

    attr_reader :session
  end
end
