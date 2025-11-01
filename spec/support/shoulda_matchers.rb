# frozen_string_literal: true

# Zorg dat de gem bestaat; anders geen hard crash tijdens load
begin
  require "shoulda/matchers"

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
rescue LoadError
  warn "[WARN] shoulda-matchers not loaded (gem missing)."
end
