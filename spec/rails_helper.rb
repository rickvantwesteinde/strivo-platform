# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
# Add additional requires below this line. Rails is not loaded until this point!

# Laad alle helpers uit spec/support/
# (Gebruik sort zodat ze in vaste volgorde geladen worden)
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!
