# frozen_string_literal: true

module Storefront
  class SessionsController < BaseController
    def show
      @session = Session.find(params[:id])

      confirmed_bookings = Booking.where(session: @session, status: Booking.statuses[:confirmed])
      @occupancy = confirmed_bookings.count
      @spots_left = [@session.capacity - @occupancy, 0].max
      @booking   = confirmed_booking_for_current_user
    end

    private

    def confirmed_booking_for_current_user
      return unless current_spree_user

      Booking.find_by(session: @session, user: current_spree_user, status: Booking.statuses[:confirmed])
    end
  end
end
