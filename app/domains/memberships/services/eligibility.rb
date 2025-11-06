module Memberships
  module Services
    class Eligibility
      def initialize(user:, gym:)
        @user, @gym = user, gym
      end

      # TODO: vervang met échte check zodra je subscriptions hebt
      def active_for_gym?
        false
      end
    end
  end
end
