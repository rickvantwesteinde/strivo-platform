# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
    include Devise::Controllers::Helpers
    include Spree::Core::ControllerHelpers::Auth
    include Storefront::CreditsHelper

    before_action :require_spree_login
    before_action :set_current_gym

    helper Storefront::CreditsHelper
    helper_method :current_gym, :current_spree_user

    private

    # Spree standaard login guard
    def require_spree_login
      unless spree_current_user
        redirect_to spree_login_path
      end
    end

    def set_current_gym
      @current_gym = spree_current_user&.gyms&.first || Gym.first
    end

    def current_gym
      @current_gym
    end
  end
end
