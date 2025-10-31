# frozen_string_literal: true

module Storefront
  class ClassesController < BaseController
    def index
      @class_types = ClassType.order(:name)
      upcoming_sessions = Session
        .where('starts_at >= ?', Time.current)
        .includes(:class_type, trainer: :user)
        .order(:starts_at)
      @sessions_by_class_type = upcoming_sessions.group_by(&:class_type_id)
      session_ids = upcoming_sessions.map(&:id)
      @bookings_count_by_session = Booking
        .where(session_id: session_ids, status: Booking.statuses[:confirmed])
        .group(:session_id)
        .count
    end
  end
end
