# frozen_string_literal: true
class ClubController < ApplicationController
  layout "spree_application"

  def index
    @gym = Gym.first
  end
end