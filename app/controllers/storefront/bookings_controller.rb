# frozen_string_literal: true

module Storefront
  class BookingsController < BaseController
    def create
      session_record = Session.find(params[:session_id])
      BookingManager.new(session: session_record, user: current_spree_user).book!
      redirect_to storefront_session_path(session_record),
                  notice: I18n.t('storefront.bookings.created', default: 'Boeking aangemaakt.')
    rescue BookingManager::BookingError => e
      redirect_to storefront_session_path(session_record), alert: e.message
    end

    def destroy
      booking = Booking.find(params[:id])
      BookingManager.new(session: booking.session, user: current_spree_user).cancel!(booking)
      redirect_to storefront_session_path(booking.session),
                  notice: I18n.t('storefront.bookings.canceled', default: 'Boeking geannuleerd.')
    rescue BookingManager::BookingError => e
      redirect_to storefront_session_path(booking.session), alert: e.message
    end
  end
end
