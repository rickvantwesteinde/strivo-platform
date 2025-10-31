# frozen_string_literal: true

FactoryBot.define do
  factory :subscription_plan do
    gym
    sequence(:name) { |n| "Plan #{n}" }
    per_week { 2 }
    price_cents { 5000 }
    unlimited { false }

    trait :unlimited do
      name { 'Unlimited Monthly' }
      unlimited { true }
      per_week { 0 }
      price_cents { 9900 }
    end

    trait :basic do
      name { 'Basic' }
      per_week { 2 }
      price_cents { 4999 }
    end

    trait :plus do
      name { 'Plus' }
      per_week { 4 }
      price_cents { 7999 }
    end
  end
end
