# frozen_string_literal: true

# -----------------------------------------------------------------------------
# Shoulda Matchers configuratie met veilige fallback.
#
# Doel:
#   - Integreert Shoulda Matchers met RSpec + Rails
#   - Crasht niet als de gem ontbreekt (bijv. in CI of bij minimale test setups)
#
# Werking:
#   - Probeert de gem te laden
#   - Als dat lukt → standaard integratie
#   - Als dat mislukt → toont waarschuwing en gaat verder zonder shoulda
#
# -----------------------------------------------------------------------------

begin
  require "shoulda-matchers"

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  puts "[INFO] Shoulda Matchers succesvol geïntegreerd."
rescue LoadError, NameError => e
  warn "[WARN] Shoulda Matchers niet geladen (#{e.class}: #{e.message}). " \
       "RSpec draait door zonder Shoulda-matchers."
end
