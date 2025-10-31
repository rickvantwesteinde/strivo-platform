# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include Devise::Controllers::Helpers

      before_action :authenticate_spree_user!

      private

      def current_user
        current_spree_user
      end

      def render_error(message, status = :unprocessable_entity)
        render json: { error: message }, status: status
      end
    end
  end
end
