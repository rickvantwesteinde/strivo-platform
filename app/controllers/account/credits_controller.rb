# frozen_string_literal: true

module Account
  class CreditsController < Spree::StoreController
    before_action :authenticate_spree_user!

    def index
      @gym = respond_to?(:current_gym, true) ? current_gym : Gym.first
      @balance = CreditLedger.where(user: spree_current_user, gym: @gym).sum(:amount)
      @entries = CreditLedger
                   .where(user: spree_current_user, gym: @gym)
                   .order(created_at: :desc)
                   .limit(50)

      # Optional/veilig: probeer abonnee-info op te halen als het model bestaat
      @subscription =
        if defined?(Subscription)
          Subscription.where(user: spree_current_user, gym: @gym).order(created_at: :desc).first
        else
          nil
        end
    end
  end
end