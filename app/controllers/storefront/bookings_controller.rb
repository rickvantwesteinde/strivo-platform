# frozen_string_literal: true

module Storefront
  class BookingsController < BaseController
    def create
      session_record = current_gym.sessions.find(params[:session_id])
      manager = BookingManager.new(session: session_record, user: current_spree_user, membership: current_membership)
      manager.book!

      redirect_to storefront_session_path(session_record, gym_slug: current_gym.slug),
                  notice: I18n.t('storefront.bookings.created', default: 'Boeking aangemaakt.')
    rescue BookingManager::BookingError => e
      redirect_to storefront_session_path(session_record, gym_slug: current_gym.slug), alert: e.message
    end

    def destroy
      # Haal alleen boekingen op die van de huidige user zijn
      booking  = current_spree_user.bookings.find(params[:id])
      ensure_same_gym!(booking)
      manager  = BookingManager.new(session: booking.session, user: current_spree_user, membership: current_membership)
      manager.cancel!(booking: booking) # expliciet keyword, maar ondersteunt nu ook positioneel

      redirect_to storefront_session_path(booking.session, gym_slug: current_gym.slug),
                  notice: I18n.t('storefront.bookings.canceled', default: 'Boeking geannuleerd.')
    rescue BookingManager::BookingError => e
      redirect_to storefront_session_path(booking.session, gym_slug: current_gym.slug), alert: e.message
    end

    private

    def ensure_same_gym!(booking)
      raise BookingManager::BookingError, I18n.t('storefront.bookings.wrong_gym', default: 'Deze boeking hoort bij een andere locatie.') if booking.session.gym != current_gym
    end
  end
end
