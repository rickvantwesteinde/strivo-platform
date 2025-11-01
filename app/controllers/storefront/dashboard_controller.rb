# frozen_string_literal: true

module Storefront
  class DashboardController < Storefront::BaseController
    def show
      # Credits voor huidige gebruiker
      @credits = CreditLedger.where(user: spree_current_user, gym: current_gym).sum(:amount)

      # SESSIES VAN VANDAAG
      @sessions_today = Session
        .where(start_at: Time.current.beginning_of_day..Time.current.end_of_day)
        .order(:start_at)
        .includes(:class_type, trainer: :user)
    end
  end
end