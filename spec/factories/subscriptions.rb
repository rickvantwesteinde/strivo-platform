# spec/factories/subscriptions.rb
FactoryBot.define do
  factory :subscription do
    association :user, factory: :spree_user
    association :subscription_plan  # ← correcte factory naam
    gym { subscription_plan.gym }   # ← gebruik de association
    starts_on { Date.current.beginning_of_month }
    status { :active }

    trait :canceled do
      status { :canceled }
      ended_at { 1.day.ago }
    end

    trait :next_month do
      starts_on { 1.month.from_now.beginning_of_month }
    end
  end
end