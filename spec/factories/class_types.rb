# frozen_string_literal: true

FactoryBot.define do
  factory :class_type do
    association :gym
    sequence(:name) { |n| "Class #{n}" }
    description { "Workout" }
    default_capacity { 14 }
    default_duration_minutes { 60 }
    default_cancellation_cutoff_hours { 6 }
  end
end