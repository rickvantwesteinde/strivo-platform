Rails.application.configure do
  config.force_ssl = true
  config.assume_ssl = true if config.respond_to?(:assume_ssl)
  config.ssl_options = { hsts: false }  # HSTS via Nginx, niet via Rails
end
