# spec/rails_helper.rb
# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require File.expand_path('../config/environment', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'

# Houd de testdatabase synchroon met migraties
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# Laad alle support helpers (incl. shoulda, capybara, factory_bot, etc.)
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # FactoryBot short-hands
  config.include FactoryBot::Syntax::Methods

  # Transacties per test (snel & schoon)
  config.use_transactional_fixtures = true

  # Spec type afleiden uit pad (model/controller/feature/system)
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
