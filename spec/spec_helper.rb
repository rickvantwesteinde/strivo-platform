# spec/spec_helper.rb
# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  enable_coverage :branch
  add_filter %r{^/config/}
  add_filter %r{^/spec/}
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Run focused specs with :focus, or everything if none focused
  config.filter_run_when_matching :focus

  # Persist example status for --only-failures / --next-failure
  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.disable_monkey_patching!

  # Randomize to surface order dependencies
  config.order = :random
  Kernel.srand config.seed
end
