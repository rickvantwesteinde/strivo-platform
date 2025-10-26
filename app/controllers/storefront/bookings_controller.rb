# frozen_string_literal: true

module Storefront
  class BookingsController < BaseController
    def create
      session_record = Session.find(params[:session_id])
      manager = BookingManager.new(session: session_record, user: current_spree_user)
      manager.book!

      redirect_to storefront_session_path(session_record),
                  notice: I18n.t('storefront.bookings.created', default: 'Boeking aangemaakt.')
    rescue BookingManager::BookingError => e
      redirect_to storefront_session_path(session_record), alert: e.message
    end

    def destroy
      # Haal alleen boekingen op die van de huidige user zijn
      booking  = current_spree_user.bookings.find(params[:id])
      manager  = BookingManager.new(session: booking.session, user: current_spree_user)
      manager.cancel!(booking: booking) # expliciet keyword, maar ondersteunt nu ook positioneel

      redirect_to storefront_session_path(booking.session),
                  notice: I18n.t('storefront.bookings.canceled', default: 'Boeking geannuleerd.')
    rescue BookingManager::BookingError => e
      redirect_to storefront_session_path(booking.session), alert: e.message
    end
  end
end
