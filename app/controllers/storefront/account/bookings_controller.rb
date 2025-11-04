# frozen_string_literal: true

module Storefront
  module Account
    class BookingsController < Storefront::BaseController
      def index
        scope = spree_current_user.bookings
                                  .joins(:session)
                                  .where(sessions: { gym_id: current_gym.id })
        @upcoming_bookings = scope.where('sessions.starts_at >= ?', Time.current).order('sessions.starts_at ASC').includes(:session)
        @past_bookings = scope.where('sessions.starts_at < ?', Time.current).order('sessions.starts_at DESC').includes(:session)

        @active_membership = current_membership
        @remaining_credits = if current_membership&.credit?
                               CreditLedger.remaining_for(user: spree_current_user, gym: current_gym)
                             else
                               nil
                             end
      end
    end
  end
end
