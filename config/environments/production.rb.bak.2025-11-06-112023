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

  # Static files (Rails alleen als env is gezet; primair via NGINX)
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.year.to_i}"
  }

  # Assets
  config.asset_host = "https://strivofit.com"

  # Storage
  config.active_storage.service = :local

  # SSL: NGINX doet HSTS; hier alleen force_ssl en hsts uit
  config.force_ssl   = true
  config.ssl_options = { hsts: false }

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

  # Hosts (optioneel localhost vrijgeven voor curl zonder Host-header)
  config.hosts << "strivofit.com"
  config.hosts << "www.strivofit.com"
  # config.hosts << "127.0.0.1"
  # config.hosts << "localhost"
end
