Rails.application.configure do
  # Draai zonder HTTPS tot Nginx TLS heeft
  config.force_ssl = false
  if config.respond_to?(:assume_ssl=)
    config.assume_ssl = false
  end
  # Voorkom 422 bij Origin mismatch zolang we nog niet op HTTPS zitten
  config.action_controller.forgery_protection_origin_check = false
end
