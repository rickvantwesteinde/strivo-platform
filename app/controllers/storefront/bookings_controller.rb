# frozen_string_literal: true

module Storefront
  class BookingsController < BaseController
    def create
      session = Session.find(params[:session_id])
      manager = BookingManager.new(session: session, user: current_spree_user)
      manager.book!
      flash[:notice] = t('.success', default: 'Boeking bevestigd!')
      redirect_to storefront_session_path(session)
    rescue BookingManager::BookingError => e
      flash[:alert] = e.message
      redirect_to storefront_session_path(session)
    end

    def destroy
      booking = current_spree_user.bookings.find(params[:id])
      manager = BookingManager.new(session: booking.session, user: current_spree_user)
      manager.cancel!(booking: booking)
      flash[:notice] = t('.success', default: 'Boeking geannuleerd.')
      redirect_to storefront_session_path(booking.session)
    rescue BookingManager::BookingError => e
      flash[:alert] = e.message
      redirect_to storefront_session_path(booking.session)
    end
  end
end
