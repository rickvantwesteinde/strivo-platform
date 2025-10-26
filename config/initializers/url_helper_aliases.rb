# config/initializers/url_helper_aliases.rb
# Zorg dat spree_login_path overal beschikbaar is (controllers, views, specs)
Rails.application.config.to_prepare do
  app_helpers   = Rails.application.routes.url_helpers
  spree_helpers = Spree::Core::Engine.routes.url_helpers

  # Definieer spree_login_path als hij niet bestaat
  unless app_helpers.method_defined?(:spree_login_path)
    app_helpers.module_eval do
      def spree_login_path
        helpers = Spree::Core::Engine.routes.url_helpers

        if helpers.respond_to?(:spree_login_path)
          helpers.spree_login_path
        elsif helpers.respond_to?(:new_spree_user_session_path)
          helpers.new_spree_user_session_path
        elsif helpers.respond_to?(:login_path)
          helpers.login_path
        else
          '/login'
        end
      end
    end
  end

  # <<-- Dit is de extra stap die nog miste
  # Voeg ook toe aan ApplicationController, zodat alle controllers/views 'm kennen
  ApplicationController.helper_method :spree_login_path if ApplicationController.method_defined?(:helper_method)
end
