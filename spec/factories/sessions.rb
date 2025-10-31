FactoryBot.define do
  factory :session do
    class_type { association :class_type }
    trainer { association :trainer }
    starts_at { 1.hour.from_now }
    duration_minutes { 60 }
  end
end
