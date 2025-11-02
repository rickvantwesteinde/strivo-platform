# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# ✅ Laad test-helpers die een constante definiëren vóór support-files:
#    - voorkomt NameError: uninitialized constant FactoryBot / Shoulda
require "factory_bot_rails"
require "shoulda-matchers"

# (optioneel, maar handig voor feature/system specs)
begin
  require "capybara/rails"
rescue LoadError
  # capybara is optioneel; negeren als niet aanwezig
end

# Laad alles in spec/support (matchers, helpers, etc.)
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Houd schema in sync
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Gebruik DB-transacties per example
  config.use_transactional_fixtures = true

  # Laat RSpec het spec-type afleiden op basis van pad (controllers/, requests/, etc.)
  config.infer_spec_type_from_file_location!

  # Minder ruis in backtraces
  config.filter_rails_from_backtrace!

  # ✅ Extra veiligheid: FactoryBot helpers direct beschikbaar
  #    (werkt ook als je spec/support/factory_bot.rb hebt; dubbele include is oké)
  if defined?(FactoryBot)
    config.include FactoryBot::Syntax::Methods
  end

  # DatabaseCleaner (alleen als aanwezig)
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

# ✅ Shoulda Matchers integratie (werkt ook als je dit al in spec/support/shoulda_matchers.rb hebt)
if defined?(Shoulda::Matchers)
  Shoulda::Matchers.configure do |cfg|
    cfg.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
