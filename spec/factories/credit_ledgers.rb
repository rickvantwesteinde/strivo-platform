# frozen_string_literal: true

FactoryBot.define do
  factory :credit_ledger do
    gym
    association :user, factory: :spree_user
    amount { 1 }
    reason { :monthly_grant }
    metadata { {} }

    trait :booking_charge do
      amount { -1 }
      reason { :booking_charge }
      association :booking
    end

    trait :booking_refund do
      amount { 1 }
      reason { :booking_refund }
      association :booking
    end
  end
end
