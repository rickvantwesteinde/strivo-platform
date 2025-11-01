# spec/support/capybara.rb
# frozen_string_literal: true

require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

# Headless Chrome voor JS tests (system/feature met js: true)
Capybara.register_driver :headless_chrome do |app|
  opts = Selenium::WebDriver::Chrome::Options.new
  opts.add_argument('--headless=new')
  opts.add_argument('--no-sandbox')
  opts.add_argument('--disable-gpu')
  opts.add_argument('--window-size=1400,1400')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: opts)
end

Capybara.javascript_driver = :headless_chrome
Capybara.default_driver   = :rack_test
