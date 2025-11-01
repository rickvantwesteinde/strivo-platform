# frozen_string_literal: true

# Zorgt dat er in test altijd precies één gym bestaat.
RSpec.configure do |config|
  config.before(:suite) do
    Gym.find_or_create_by!(slug: "default-gym") do |g|
      g.name = "Default Gym"
    end
  end
end
