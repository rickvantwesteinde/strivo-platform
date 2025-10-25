module Storefront
  class SessionsController < BaseController
    def show
      @session = Session.includes(:class_type, :gym, bookings: :user).find(params[:id])
      @booking = @session.bookings.confirmed.find_by(user: current_spree_user)
      @occupancy = @session.spots_taken
      @spots_left = @session.spots_left
    end
  end
end
