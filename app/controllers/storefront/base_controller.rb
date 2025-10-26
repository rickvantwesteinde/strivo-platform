# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
    # Haal zowel Devise- als Spree-auth helpers binnen
    include Devise::Controllers::Helpers
    include Spree::Core::ControllerHelpers::Auth

    include Storefront::CreditsHelper

    before_action :authenticate_spree_user!

    helper Storefront::CreditsHelper
    helper_method :default_gym, :current_spree_user

    private

    # ✅ Uniforme current_spree_user, ook als alleen spree_current_user bestaat
    def current_spree_user
      return super if defined?(super) # als Devise 'current_spree_user' al definieert
      return spree_current_user if respond_to?(:spree_current_user, true)

      nil
    end

    # ✅ Accepteer meerdere manieren waarop “ingelogd” kan zijn
    def authenticate_spree_user!
      signed_in =
        (respond_to?(:spree_user_signed_in?, true) && spree_user_signed_in?) ||
        current_spree_user.present?

      return if signed_in

      # Optioneel: onthoud waar we heen wilden
      store_location if respond_to?(:store_location, true)

      redirect_to '/login'
    end

    def default_gym
      @default_gym ||= Gym.order(:id).first
    end
  end
end
