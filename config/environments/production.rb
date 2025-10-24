require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Serve images/CSS/JS via same host (zet uit als je een CDN gaat gebruiken).
  config.asset_host = "https://strivofit.com"

  # Store uploaded files on the local file system.
  config.active_storage.service = :local

  # App draait achter Nginx TLS-terminatie.
  config.assume_ssl = true

  # Force HTTPS, maar HSTS laten we door Nginx doen (om dubbele header te voorkomen).
  config.force_ssl = true
  config.ssl_options = { hsts: false }

  # Logging
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  # Cache store (fix typefout REDIS env + correcte syntax)
  if ENV["REDIS_CACHE_URL"].present?
    cache_servers = ENV["REDIS_CACHE_URL"].split(",")
    config.cache_store = :redis_cache_store, {
      url: cache_servers,
      connect_timeout:    30,
      read_timeout:       0.2,
      write_timeout:      0.2,
      reconnect_attempts: 2,
    }
  else
    config.cache_store = :memory_store
  end

  # Active Job
  config.active_job.queue_adapter = :sidekiq

  # Mailer host
  config.action_mailer.default_url_options = { host: "strivofit.com", protocol: "https" }

  # I18n & AR
  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]

  # (optioneel) whitelist hosts:
  # config.hosts = ["strivofit.com", /.*\.strivofit\.com/]

  # Render-seed fallback (laat staan, maar alleen gebruiken als env gezet is)
  if ENV["RENDER_EXTERNAL_URL"].present?
    Rails.application.routes.default_url_options[:host] = ENV["RENDER_EXTERNAL_URL"]
  end

  # **Belangrijk voor absolute links in menu/navigation**
  Rails.application.routes.default_url_options[:host] = "strivofit.com"
  config.action_controller.default_url_options = { host: "strivofit.com" }
end
