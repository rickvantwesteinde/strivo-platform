FactoryBot.define do
  factory :booking do
    association :session
    gym { session.gym }
    association :user, factory: :spree_user
    subscription_plan { create(:subscription_plan, gym: gym) }
    status { :confirmed }
    used_credits { 1 }
  end
end
