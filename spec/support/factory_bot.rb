# frozen_string_literal: true

RSpec.configure do |config|
  # Zorg voor mooie, korte helpers: build(:user) i.p.v. FactoryBot.build(:user)
  config.include FactoryBot::Syntax::Methods

  # In Rails laadt factory_bot_rails automatisch je factories uit spec/factories.
  # Extra defensieve laadactie kan, maar is niet vereist:
  # config.before(:suite) { FactoryBot.find_definitions }
end
