# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
    include Devise::Controllers::Helpers
    include Spree::Core::ControllerHelpers::Auth
    include Storefront::CreditsHelper

    before_action :require_spree_login
    before_action :set_current_gym

    helper Storefront::CreditsHelper
    helper_method :current_gym, :default_gym, :spree_current_user

    private

    def require_spree_login
      redirect_to spree_login_path unless spree_current_user
    end

    # Single-gym setup (later kun je dit vervangen door user->gyms)
    def set_current_gym
      @current_gym = default_gym
    end

    def current_gym
      @current_gym || default_gym
    end

    def default_gym
      @default_gym ||= Gym.first
    end
  end
end
