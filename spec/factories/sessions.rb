# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    class_type { association :class_type }
    trainer    { association :trainer }
    start_at   { 1.hour.from_now }  # ← wijziging hier
    duration_minutes { 60 }
    capacity { 14 }                 # mag blijven of toevoegen
  end
end