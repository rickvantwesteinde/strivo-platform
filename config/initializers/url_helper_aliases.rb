# Map RSpec/request-spec helpers that expect spree_login_path to Spree's login_path
Rails.application.config.to_prepare do
  rails_helpers = Rails.application.routes.url_helpers

  unless rails_helpers.method_defined?(:spree_login_path)
    rails_helpers.module_eval do
      def spree_login_path
        Spree::Core::Engine.routes.url_helpers.login_path
      end
    end
  end
end
