# frozen_string_literal: true

Rails.application.configure do
  # Keys
  config.secret_key_base    = ENV.fetch("SECRET_KEY_BASE")
  config.require_master_key = false

  # Performance
  config.enable_reloading = false
  config.eager_load       = true

  # Errors & caching
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Static files (primair via Nginx; Rails mag ook dienen als fallback)
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.year.to_i}"
  }

  # Assets
  config.asset_host = "https://strivofit.com"

  # Storage
  config.active_storage.service = :local

  # --- SSL / HSTS ---
  # Nginx forceert HTTPS en zet HSTS; Rails hoeft geen HSTS te sturen.
  config.force_ssl   = false
  config.ssl_options = { hsts: false }
  # Zorg dat Rails per ongeluk geen HSTS header meestuurt:
  config.action_dispatch.default_headers.delete('Strict-Transport-Security')

  # URL helpers
  config.action_controller.default_url_options = { host: "strivofit.com", protocol: "https" }

  # Logging
  config.log_tags  = [:request_id]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.logger    = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Misc
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  # Cache store
  if ENV["REDIS_CACHE_URL"].present?
    config.cache_store = :redis_cache_store, {
      url: ENV["REDIS_CACHE_URL"],
      error_handler: -> (method, returning, exception) {
        Rails.logger.warn("Redis cache error: #{method} -> #{exception.class}: #{exception.message}")
      }
    }
  else
    config.cache_store = :memory_store, { size: 64.megabytes }
  end

  # Hosts (HTTP Host Authorization)
  config.hosts << "strivofit.com"
  config.hosts << "www.strivofit.com"
  # config.hosts << "127.0.0.1"
  # config.hosts << "localhost"
end