# frozen_string_literal: true

FactoryBot.define do
  factory :class_type do
    gym
    sequence(:name) { |n| "Class Type #{n}" }
    description { 'A great workout class' }
    default_capacity { 14 }
    default_duration_minutes { 60 }
    default_cancellation_cutoff_hours { 6 }

    trait :yoga do
      name { 'Yoga Flow' }
    end

    trait :hiit do
      name { 'HIIT Blast' }
      default_duration_minutes { 45 }
    end
  end
end
