# frozen_string_literal: true

module Storefront
  class SessionsController < BaseController
    def show
      @session = Session.find(params[:id])

      # Bepaal of huidige user al geboekt heeft (spec kijkt hiernaar)
      @existing_booking = @session.bookings.find_by(user: current_spree_user, status: :confirmed)
      @already_booked   = @existing_booking.present?
    end
  end
end
