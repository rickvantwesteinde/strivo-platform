module Credits
  module Services
    class BalanceCalculator
      def initialize(user:, gym:)
        @user, @gym = user, gym
      end

      def call
        CreditLedger.where(user: @user, gym: @gym).sum(:amount)
      end
    end
  end
end
