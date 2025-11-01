# frozen_string_literal: true

FactoryBot.define do
  factory :gym do
    sequence(:name) { |n| "Gym #{n}" }
    sequence(:slug) { |n| "gym-#{n}" }
    address { "Amsterdam" }
  end
end