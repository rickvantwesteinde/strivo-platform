module Strivo
  module Admin
    class ApplicationController < Spree::Admin::BaseController
      rescue_from CanCan::AccessDenied do |_exception|
        redirect_to main_app.new_spree_admin_user_session_path, alert: 'You are not authorized to access this page.'
      end
    end
  end
end
