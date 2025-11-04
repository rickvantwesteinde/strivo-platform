module DeviseSpreeHelpers
  def sign_in_spree(user)
    sign_in user, scope: :spree_user
  end
end

RSpec.configure do |config|
  config.include DeviseSpreeHelpers, type: :request
  config.include DeviseSpreeHelpers, type: :feature
end
