FactoryBot.define do
  factory :spree_user, class: 'Spree::User' do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
  end
end
