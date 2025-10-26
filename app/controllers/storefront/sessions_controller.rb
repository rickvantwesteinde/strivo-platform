# frozen_string_literal: true

module Storefront
  class SessionsController < BaseController
    def show
      @session = Session.find(params[:id])
    end
  end
end
