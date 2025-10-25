module Storefront
  module Account
    class BookingsController < BaseController
      def index
        bookings = current_spree_user.bookings.includes(session: [:class_type, :gym])
        sorted = bookings.sort_by { |booking| booking.session.starts_at }
        @upcoming_bookings, @past_bookings = sorted.partition do |booking|
          booking.status_confirmed? && booking.session.starts_at >= Time.current
        end
        @past_bookings = @past_bookings.sort_by { |booking| booking.session.starts_at }.reverse
        @remaining_credits = remaining_credits(current_spree_user, default_gym)
      end
    end
  end
end
