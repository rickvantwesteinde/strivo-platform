# frozen_string_literal: true

FactoryBot.define do
  factory :spree_user, class: "Spree::User" do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    confirmed_at { Time.current if Spree::User.column_names.include?("confirmed_at") }
  end
end