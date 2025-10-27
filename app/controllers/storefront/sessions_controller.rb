# frozen_string_literal: true

module Storefront
  class SessionsController < BaseController
    def show
      @session = Session.find(params[:id])

      # Data die de view/spec verwacht
      @occupancy = @session.bookings.where(status: :confirmed).count
      @spots_left = @session.spots_left
      @booking   = @session.bookings.find_by(user: current_spree_user, status: :confirmed)
    end
  end
end
