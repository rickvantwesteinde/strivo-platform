# frozen_string_literal: true

FactoryBot.define do
  factory :gym do
    sequence(:name) { |n| "Gym #{n}" }
    sequence(:slug) { |n| "gym-#{n}" }
    address { 'Amsterdam' }

    after(:create) do |gym|
      gym.policies.first_or_create!(
        cancel_cutoff_hours: 6,
        rollover_limit: 2,
        max_active_daily_bookings: 1
      )
    end
  end
end
