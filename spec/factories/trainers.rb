# frozen_string_literal: true

FactoryBot.define do
  factory :trainer do
    gym
    association :user, factory: :spree_user
    bio { 'Certified instructor with 5 years experience' }

    trait :with_bio do
      bio { 'Certified yoga instructor with 5 years experience' }
    end
  end
end
