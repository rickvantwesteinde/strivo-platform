# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Devise::Test::IntegrationHelpers, type: :request
end
