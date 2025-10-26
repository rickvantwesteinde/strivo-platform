# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
    # Houd helpers beschikbaar
    include Devise::Controllers::Helpers
    include Spree::Core::ControllerHelpers::Auth
    include Storefront::CreditsHelper

    # Enige guard die we willen: redirect ALTIJD naar spree_login_path
    before_action :require_spree_login

    helper Storefront::CreditsHelper
    helper_method :default_gym, :current_spree_user

    private

    # Eenduidige accessor voor de ingelogde user
    def current_spree_user
      return super if defined?(super)
      return spree_current_user if respond_to?(:spree_current_user, true)
      nil
    end

    # <<< Belangrijk: simpele guard die exact naar spree_login_path gaat >>>
    def require_spree_login
      signed_in =
        (respond_to?(:spree_user_signed_in?, true) && spree_user_signed_in?) ||
        current_spree_user.present?

      return if signed_in

      # Dit is de helper die je in config/initializers/url_helper_aliases.rb hebt aangemaakt
      redirect_to spree_login_path
    end

    def default_gym
      @default_gym ||= Gym.order(:id).first
    end
  end
end
