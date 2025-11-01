# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# Laad alles in spec/support (matchers, helpers, etc.)
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Houd schema in sync
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # DatabaseCleaner (alleen als je 'm gebruikt)
  if defined?(DatabaseCleaner)
    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end
    config.around(:each) do |example|
      DatabaseCleaner.cleaning { example.run }
    end
  end
end
