# config/initializers/url_helper_aliases.rb
# Zorg dat spree_login_path overal beschikbaar is (controllers, views, specs)

Rails.application.config.to_prepare do
  app_helpers   = Rails.application.routes.url_helpers

  # Definieer spree_login_path één keer op de app URL helpers
  unless app_helpers.method_defined?(:spree_login_path)
    app_helpers.module_eval do
      def spree_login_path
        # Prefer Spree's eigen /login als die route bestaat, anders val terug op Devise
        if Spree::Core::Engine.routes.url_helpers.respond_to?(:login_path)
          Spree::Core::Engine.routes.url_helpers.login_path
        else
          # Dit is wat er in CI daadwerkelijk gebruikt wordt
          '/user/sign_in'
        end
      end
    end
  end

  # Maak 'm beschikbaar in controllers en views
  ApplicationController.helper_method :spree_login_path if ApplicationController.respond_to?(:helper_method)
end
