# frozen_string_literal: true
module Storefront
  class CreditsController < Storefront::BaseController
    before_action :authenticate_spree_user!

    def show
      gym = (respond_to?(:current_gym) && current_gym) || Gym.first
      @balance = CreditLedger.balance_for(user: spree_current_user, gym: gym)
      @entries = CreditLedger.where(user: spree_current_user, gym: gym)
                             .order(created_at: :desc)
                             .limit(100)
    end
  end
end
