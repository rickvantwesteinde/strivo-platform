class Account::CreditsController < Storefront::BaseController
  before_action :require_spree_login
  def index
    @balance = Credits::Services::BalanceCalculator.new(user: spree_current_user, gym: current_gym).call
    @entries = Credits::Services::HistoryQuery.new(user: spree_current_user, gym: current_gym).call
  end
end
