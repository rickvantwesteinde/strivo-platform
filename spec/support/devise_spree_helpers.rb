module DeviseSpreeHelpers
  def sign_in_spree(user)
    if respond_to?(:sign_in)
      sign_in(user, scope: :spree_user)
    else
      login_as(user, scope: :spree_user)
    end
  end

  def sign_in_spree_admin(admin)
    if respond_to?(:sign_in)
      sign_in(admin, scope: :spree_admin_user)
    else
      login_as(admin, scope: :spree_admin_user)
    end
  end
end

RSpec.configure do |config|
  config.include DeviseSpreeHelpers, type: :request
  config.include DeviseSpreeHelpers, type: :feature
end
