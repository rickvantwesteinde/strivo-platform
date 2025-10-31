# frozen_string_literal: true

module Storefront
  module Account
    class BookingsController < Storefront::BaseController
      def index
        @bookings = current_spree_user
          .bookings
          .includes(session: [:class_type, trainer: :user])
          .order(created_at: :desc)
        @remaining_credits = remaining_credits(current_spree_user, current_gym)
        @upcoming_bookings, @past_bookings = @bookings.partition { |booking| booking.session.starts_at >= Time.current }
      end
    end
  end
end
