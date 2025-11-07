# app/controllers/storefront/account/bookings_controller.rb
# frozen_string_literal: true

module Storefront
  module Account
    class BookingsController < Storefront::BaseController
      before_action :authenticate_spree_user!

      def index
        unless current_gym
          redirect_to main_app.root_path, alert: "No gym selected." and return
        end

        base = Booking.where(user: spree_current_user)
                      .joins(:session)
                      .where(sessions: { gym_id: current_gym.id })

        @bookings = base
          .includes(session: [:class_type, { trainer: :user }])
          .order('sessions.start_at ASC')

        now = Time.current
        @upcoming_bookings = base.where('sessions.start_at >= ?', now).order('sessions.start_at ASC')
        @past_bookings     = base.where('sessions.start_at < ?',  now).order('sessions.start_at DESC')

        @active_membership = respond_to?(:current_membership, true) ? current_membership : nil
        @remaining_credits =
          if @active_membership && @active_membership.respond_to?(:credit?) && @active_membership.credit?
            CreditLedger.remaining_for(user: spree_current_user, gym: current_gym)
          end
      end
    end
  end
end