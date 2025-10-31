# frozen_string_literal: true

FactoryBot.define do
  factory :waitlist_entry do
    session
    association :user, factory: :spree_user
    position { 1 }
  end
end
