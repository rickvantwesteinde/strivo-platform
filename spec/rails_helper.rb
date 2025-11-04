# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
# Add additional requires below this line. Rails is not loaded until this point!

# Support files are already loaded by spec_helper.rb, no need to load them again

Rails.application.routes.default_url_options[:host] = 'www.example.com'

RSpec.configure do |config|
  config.before(:suite) do
    I18n.default_locale = :nl
    I18n.locale = :nl
    Money.default_currency = Money::Currency.find(:eur)
  end
end

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!
