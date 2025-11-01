# spec/rails_helper.rb
# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require File.expand_path('../config/environment', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'

# Maintain test schema
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# Load everything in spec/support/**/*.rb
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you use ActiveJob
  # config.include ActiveJob::TestHelper

  # If you use FactoryBot:
  config.include FactoryBot::Syntax::Methods

  # Use transactions by default
  config.use_transactional_fixtures = true

  # infer spec type from location (model/controller/feature etc.)
  config.infer_spec_type_from_file_location!

  # filter Rails lines in backtraces
  config.filter_rails_from_backtrace!
end
