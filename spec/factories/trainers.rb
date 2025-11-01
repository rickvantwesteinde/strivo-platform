# frozen_string_literal: true

FactoryBot.define do
  factory :trainer do
    association :gym
    association :user, factory: :spree_user
    bio { "Coach" }
  end
end