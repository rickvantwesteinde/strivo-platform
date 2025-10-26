# frozen_string_literal: true

module Storefront
  module Account
    class BookingsController < Storefront::BaseController
      def index
        @bookings = current_spree_user.bookings
                                      .includes(:session)
                                      .order(created_at: :desc)
        @credits = CreditLedger.where(user: current_spree_user).sum(:amount)
      end
    end
  end
end
