module Strivo
  module Admin
    class ApplicationController < Spree::Admin::BaseController
      rescue_from CanCan::AccessDenied do |_exception|
        redirect_to spree.admin_login_path, alert: 'You are not authorized to access this page.'
      end
    end
  end
end
