FactoryBot.define do
  factory :credit_ledger do
    association :gym
    association :user, factory: :spree_user
    amount { 1 }
    reason { :monthly_grant }
  end
end
