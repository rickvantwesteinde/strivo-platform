# app/helpers/navigation_helper.rb
module NavigationHelper
  def credits_balance_badge
    # moet ingelogd zijn
    return unless respond_to?(:spree_current_user, true) && spree_current_user

    # kies gym (fallback naar eerste gym als current_gym ontbreekt)
    gym = (respond_to?(:current_gym, true) && current_gym) || Gym.first
    return unless gym

    balance = CreditLedger.balance_for(user: spree_current_user, gym: gym)

    # gebruik Spree engine route voor store credits
    h = Spree::Core::Engine.routes.url_helpers
    link_to h.account_store_credits_path,
            class: "inline-flex items-center gap-2 rounded-full px-3 py-1 text-sm font-medium bg-gray-900 text-white hover:bg-gray-800 transition" do
      raw %(
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-10v.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
        <span>Credits: #{balance}</span>
      )
    end
  rescue => e
    Rails.logger.warn("credits_balance_badge failed: #{e.class}: #{e.message}")
    nil
  end
end