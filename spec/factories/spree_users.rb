FactoryBot.define do
  factory :spree_user, class: 'Spree::User' do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'Password1!' }
    password_confirmation { 'Password1!' }
  end
end
