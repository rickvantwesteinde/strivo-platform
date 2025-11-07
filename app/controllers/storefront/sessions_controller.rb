# frozen_string_literal: true

module Storefront
  class SessionsController < BaseController
    def show
      @session = current_gym.sessions.find(params[:id])

      @occupancy          = @session.bookings.where(status: :confirmed).count
      @spots_left         = @session.spots_left
      @booking            = @session.bookings.find_by(user: spree_current_user, status: :confirmed)
      @active_membership  = current_membership
      @booking_manager    = BookingManager.new(session: @session, user: spree_current_user, membership: @active_membership)
      @daily_cap_reached  = @booking_manager.daily_cap_reached?
    end
  end
end