# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    association :user, factory: :spree_user
    subscription_plan
    gym { subscription_plan.gym }
    starts_on { Date.current.beginning_of_month }
    status { :active }

    trait :canceled do
      status { :canceled }
      ended_at { 1.day.ago }
    end

    trait :next_month do
      starts_on { 1.month.from_now.beginning_of_month }
    end

    trait :paused do
      status { :paused }
    end
  end
end
