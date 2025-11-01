# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
    include Devise::Controllers::Helpers
    include Spree::Core::ControllerHelpers::Auth
    include Storefront::CreditsHelper

    before_action :authenticate_user!

    helper Storefront::CreditsHelper
    helper_method :current_gym

    private

    def current_gym
      @current_gym ||= spree_current_user&.gyms&.first || Gym.first
    end
  end
end
