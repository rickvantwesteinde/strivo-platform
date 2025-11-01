# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    class_type { association :class_type }
    trainer    { association :trainer }
    start_at   { 1.hour.from_now }   # <-- was starts_at
    duration_minutes { 60 }
    capacity { 14 }
  end
end