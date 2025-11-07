# frozen_string_literal: true

module Storefront
  class ClubController < Storefront::BaseController
    layout "spree_application"

    def index
      @gym = Gym.first
    end
  end
end
