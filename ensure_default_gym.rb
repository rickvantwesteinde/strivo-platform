# Zorgt dat er altijd precies 1 gym bestaat tijdens specs
RSpec.configure do |config|
  config.before(:suite) do
    Gym.find_or_create_by!(slug: "default-gym") do |g|
      g.name = "Default Gym"
    end
  end
end
