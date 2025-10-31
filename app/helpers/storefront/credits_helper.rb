module Storefront
  module CreditsHelper
    def remaining_credits(user, gym)
      CreditLedger.balance_for(user: user, gym: gym)
    end
  end
end
