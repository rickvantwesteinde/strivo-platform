# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
# Rails and support files are already loaded by spec_helper.rb

Rails.application.routes.default_url_options[:host] = 'www.example.com'

RSpec.configure do |config|
  config.before(:suite) do
    I18n.default_locale = :nl
    I18n.locale = :nl
    Money.default_currency = Money::Currency.find(:eur)
  end
end
