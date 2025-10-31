# spec/factories/bookings.rb
FactoryBot.define do
  factory :booking do
    association :session
    association :user, factory: :spree_user
    association :subscription_plan

    # Correcte gym via class_type
    gym { session.class_type.gym }

    status { :confirmed }
    used_credits { 1 }

    trait :canceled do
      status { :canceled }
      canceled_at { Time.current }
    end

    trait :no_show do
      no_show { true }
    end

    trait :late_cancel do
      canceled
      canceled_at { session.starts_at - 1.hour }
    end
  end
end