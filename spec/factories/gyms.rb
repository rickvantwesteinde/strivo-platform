FactoryBot.define do
  factory :gym do
    sequence(:name) { |n| "Gym #{n}" }
    sequence(:slug) { |n| "gym-#{n}" }
  end
end
