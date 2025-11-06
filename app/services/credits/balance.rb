module Credits
  class Balance
    def self.call(user:, gym:)
      CreditLedger.balance_for(user: user, gym: gym)
    end
  end
end
