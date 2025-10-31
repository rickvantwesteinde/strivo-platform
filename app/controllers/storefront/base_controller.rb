# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
    include Devise::Controllers::Helpers
    include Spree::Core::ControllerHelpers::Auth
    helper Storefront::CreditsHelper

    before_action :authenticate_spree_user!
    before_action :set_current_gym

    helper_method :current_gym, :current_spree_user

    private

    def set_current_gym
      @current_gym = current_spree_user.gyms.first || Gym.first
    end

    def current_gym
      @current_gym
    end
  end
end
