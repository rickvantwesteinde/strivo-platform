# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
    # Zorg dat Devise/Spree helpers beschikbaar zijn
    include Devise::Controllers::Helpers
    include Spree::Core::ControllerHelpers::Auth
    include Storefront::CreditsHelper

    before_action :authenticate_spree_user!

    helper Storefront::CreditsHelper
    helper_method :default_gym, :current_spree_user

    private

    # Eenduidige accessor voor de ingelogde user
    def current_spree_user
      return super if defined?(super)
      return spree_current_user if respond_to?(:spree_current_user, true)
      nil
    end

    # Eenduidige auth-guard die ALTIJD redirect i.p.v. action uitvoeren
    def authenticate_spree_user!
      signed_in =
        (respond_to?(:spree_user_signed_in?, true) && spree_user_signed_in?) ||
        current_spree_user.present?

      return if signed_in

      store_location if respond_to?(:store_location, true)
      redirect_to login_redirect_path
    end

    # Kies login route die in Spree aanwezig is (fallback naar Devise of /login)
    def login_redirect_path
      helpers = Spree::Core::Engine.routes.url_helpers

      if helpers.respond_to?(:spree_login_path)
        helpers.spree_login_path
      elsif helpers.respond_to?(:new_spree_user_session_path)
        helpers.new_spree_user_session_path
      elsif defined?(main_app) && main_app.respond_to?(:new_user_session_path)
        main_app.new_user_session_path
      else
        '/login'
      end
    end

    def default_gym
      @default_gym ||= Gym.order(:id).first
    end
  end
end
