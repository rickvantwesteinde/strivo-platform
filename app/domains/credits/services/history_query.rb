module Credits
  module Services
    class HistoryQuery
      DEFAULT_LIMIT = 100

      def initialize(user:, gym:, limit: DEFAULT_LIMIT)
        @user  = user
        @gym   = gym
        @limit = limit
      end

      def call
        CreditLedger.where(user: @user, gym: @gym)
                    .order(created_at: :desc)
                    .limit(@limit)
      end
    end
  end
end
