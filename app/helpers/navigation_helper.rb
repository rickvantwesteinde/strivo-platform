# frozen_string_literal: true
module NavigationHelper
  # Bepaal of een pad actief is (voor menu highlighting)
  def active_tab?(*paths)
    Array(paths).compact.any? { |p| current_page?(p) rescue false }
  end

  # Klein badge-component met huidig creditsaldo
  def credits_balance_badge
    return unless respond_to?(:spree_current_user, true) && spree_current_user

    gym = (respond_to?(:current_gym, true) && current_gym) || Gym.first
    return unless gym

    balance =
      if defined?(CreditLedger)
        CreditLedger.where(user: spree_current_user, gym: gym).sum(:amount)
      else
        0
      end

    # route naar jouw eigen credits-pagina
    path = main_app.respond_to?(:account_credits_path) ? main_app.account_credits_path : '/account/credits'

    link_to path,
            class: "inline-flex items-center gap-2 rounded-full px-3 py-1 text-sm font-medium bg-gray-900 text-white hover:bg-gray-800 transition" do
      raw <<~HTML
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-10v.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
        <span>Credits: #{balance}</span>
      HTML
    end
  rescue => e
    Rails.logger.warn("credits_balance_badge failed: #{e.class}: #{e.message}")
    nil
  end
end