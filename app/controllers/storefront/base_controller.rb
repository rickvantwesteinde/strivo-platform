# frozen_string_literal: true

module Storefront
  class BaseController < ApplicationController
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
