FactoryBot.define do
  factory :class_type do
    gym
    sequence(:name) { |n| "Class #{n}" }
    default_duration_minutes { 60 }
  end
end
