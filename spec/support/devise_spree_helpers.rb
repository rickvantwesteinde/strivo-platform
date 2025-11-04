module DeviseSpreeHelpers
  def sign_in_spree(user)
    login_as(user, scope: :spree_user)
    sign_in(user, scope: :spree_user) if respond_to?(:sign_in)
  end

  def sign_in_spree_admin(admin)
    login_as(admin, scope: :spree_admin_user)
    sign_in(admin, scope: :spree_admin_user) if respond_to?(:sign_in)
  end
end

RSpec.configure do |config|
  config.include DeviseSpreeHelpers, type: :request
  config.include DeviseSpreeHelpers, type: :feature
end
