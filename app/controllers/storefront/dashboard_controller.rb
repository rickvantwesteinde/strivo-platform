# frozen_string_literal: true

module Storefront
  class DashboardController < Storefront::BaseController
    def show
      @credits = CreditLedger.where(user: spree_current_user, gym: current_gym).sum(:amount)

      @sessions = Session
                    .where("start_at >= ?", Time.current) # <-- start_at
                    .order(:start_at)
                    .limit(10)
                    .includes(:class_type, trainer: :user)
    end
  end
end
