module Reports
  class SessionUtilization
    def initialize(session)
      @session = session
    end

    def call
      {
        session_id: session.id,
        bookings_count: session.bookings.confirmed.count,
        capacity: session.capacity,
        no_shows_count: session.bookings.where(no_show: true).count
      }
    end

    private

    attr_reader :session
  end
end
