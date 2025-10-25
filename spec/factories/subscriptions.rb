FactoryBot.define do
  factory :subscription do
    association :user, factory: :spree_user
    association :plan, factory: :subscription_plan
    gym { plan.gym }
    starts_on { Date.current.beginning_of_month }
    status { :active }
  end
end
