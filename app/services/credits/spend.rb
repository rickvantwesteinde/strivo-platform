module Credits
  class Spend
    InsufficientBalance = Class.new(StandardError)
    def self.call(user:, gym:, amount:, reason: :booking, metadata: {})
      amt = Integer(amount)
      raise ArgumentError, "amount must be positive" unless amt.positive?
      balance = CreditLedger.balance_for(user:, gym:)
      raise InsufficientBalance, "balance=#{balance}, needed=#{amt}" if balance < amt
      CreditLedger.create!(
        user: user, gym: gym, amount: -amt,
        reason: CreditLedger.reasons.fetch(reason.to_s),
        metadata: metadata
      )
    end
  end
end
