# spec/factories/subscription_plans.rb
FactoryBot.define do
  factory :subscription_plan do
    gym # ← korter en beter
    sequence(:name) { |n| "Plan #{n}" }
    per_week { 2 }
    price_cents { 5000 }
    unlimited { false }

    trait :unlimited do
      name { "Unlimited Monthly" }
      unlimited { true }
      per_week { 0 }
      price_cents { 9900 }
    end
  end
end