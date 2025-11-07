# frozen_string_literal: true

module NavigationHelper
  # === 1. Active tab detection (bestaand)
  def active_tab?(*paths)
    Array(paths).compact.any? { |p| current_page?(p) rescue false }
  end

  # === 2. Credits badge component (bestaand)
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

  # === 3. Bottom navigation tabs (nieuw)
  Tab = Struct.new(:key, :name, :path)

  def bottom_tabs
    [
      Tab.new(:home,     "Home",     main_app.root_path),
      Tab.new(:bookings, "Bookings", main_app.url_for(controller: "/account/bookings", action: :index)),
      Tab.new(:club,     "Club",     main_app.club_path),
      Tab.new(:profile,  "Profile",  main_app.url_for(controller: "/account/orders", action: :index))
    ]
  end

  def active_tab?(key)
    case key
    when :home
      current_page?(main_app.root_path)
    when :bookings
      controller_path.start_with?("account/bookings")
    when :club
      request.path == main_app.club_path
    when :profile
      request.path.start_with?("/account")
    else
      false
    end
  rescue
    false
  end

  def bottom_nav_css_for(key)
    active_tab?(key) ? "text-blue-600 font-semibold" : "text-gray-500"
  end
end