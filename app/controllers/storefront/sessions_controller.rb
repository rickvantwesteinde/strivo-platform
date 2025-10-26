# frozen_string_literal: true

module Storefront
  class SessionsController < BaseController
    def index
      @class_types = ClassType.all
      @sessions = Session.includes(:class_type, :trainer)
                         .where('starts_at >= ?', Time.zone.now.beginning_of_day)
                         .order(:starts_at)
    end

    def show
      @session = Session.find(params[:id])
      @booking = current_spree_user.bookings.find_by(session: @session)
    end
  end
end
