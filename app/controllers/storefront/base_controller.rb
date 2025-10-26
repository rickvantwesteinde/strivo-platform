# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
    # nodig voor authenticate_spree_user!
    include Devise::Controllers::Helpers

    # Spree helpers (spree_current_user e.d.)
    include Spree::Core::ControllerHelpers::Auth

    include Storefront::CreditsHelper

    before_action :authenticate_spree_user!

    helper Storefront::CreditsHelper
    helper_method :default_gym

    private

    def default_gym
      @default_gym ||= Gym.order(:id).first
    end
  end
end
