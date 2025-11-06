module NavigationHelper
  def credits_balance_badge
    return unless defined?(spree_current_user) && spree_current_user && defined?(current_gym) && current_gym

    balance = CreditLedger.balance_for(user: spree_current_user, gym: current_gym)
    link_to storefront_credits_path, class: "inline-flex items-center gap-2 rounded-full px-3 py-1 text-sm font-medium bg-gray-900 text-white hover:bg-gray-800 transition" do
      raw %(
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-10v.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
        <span>Credits: #{balance}</span>
      )
    end
  end
end
