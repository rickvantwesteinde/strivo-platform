FactoryBot.define do
  factory :subscription_plan do
    association :gym
    sequence(:name) { |n| "Plan #{n}" }
    per_week { 2 }
    price_cents { 5000 }
    unlimited { false }
  end
end
