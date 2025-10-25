FactoryBot.define do
  factory :trainer do
    association :gym
    association :user, factory: :spree_user
  end
end
