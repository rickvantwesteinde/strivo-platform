module Storefront
  module CreditsHelper
    def remaining_credits(user, gym)
      return 0 if user.nil? || gym.nil?

      CreditLedger.remaining_for(user:, gym:)
    end
  end
end
