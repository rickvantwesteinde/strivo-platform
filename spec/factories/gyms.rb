# frozen_string_literal: true

FactoryBot.define do
  factory :gym do
    sequence(:name) { |n| "Gym #{n}" }
    sequence(:slug) { |n| "gym-#{n}" }
  end

  factory :default_gym, class: "Gym" do
    name { "Default Gym" }
    slug { "default-gym" }
  end
end
