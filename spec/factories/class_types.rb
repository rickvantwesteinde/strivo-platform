FactoryBot.define do
  factory :class_type do
    association :gym
    sequence(:name) { |n| "Class Type #{n}" }
    default_capacity { 14 }
  end
end
