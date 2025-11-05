module Credits
  class Grant
    def self.call(user:, gym:, amount:, reason: :manual_grant, metadata: {})
      amt = Integer(amount)
      raise ArgumentError, "amount must be positive" unless amt.positive?
      CreditLedger.create!(
        user: user, gym: gym, amount: amt,
        reason: CreditLedger.reasons.fetch(reason.to_s),
        metadata: metadata
      )
    end
  end
end
