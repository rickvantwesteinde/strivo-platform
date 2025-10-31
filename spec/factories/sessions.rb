# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    class_type
    trainer
    starts_at { 1.hour.from_now }
    duration_minutes { 60 }
    capacity { 14 }

    trait :in_one_hour do
      starts_at { 1.hour.from_now }
    end

    trait :in_two_hours do
      starts_at { 2.hours.from_now }
    end

    trait :tomorrow do
      starts_at { 1.day.from_now.change(hour: 10, min: 0) }
    end
  end
end
