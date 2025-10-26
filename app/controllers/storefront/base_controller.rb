# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
    # Zorg dat Devise helpers zoals current_spree_user beschikbaar zijn
    include Devise::Controllers::Helpers

    # Credits helper zoals je al had
    include Storefront::CreditsHelper

    # ✅ Shim: bied altijd authenticate_spree_user! aan
    # - Als je ingelogd bent als spree_user -> OK
    # - Anders redirecten we naar de loginpagina
    before_action :authenticate_spree_user!

    helper Storefront::CreditsHelper
    helper_method :default_gym

    private

    def authenticate_spree_user!
      return if respond_to?(:current_spree_user, true) && current_spree_user.present?

      # simpele, compatibele redirect naar Devise/Spree login
      # In Spree is dit doorgaans /login
      redirect_to '/login'
    end

    def default_gym
      @default_gym ||= Gym.order(:id).first
    end
  end
end
