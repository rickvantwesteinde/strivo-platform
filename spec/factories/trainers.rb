FactoryBot.define do
  factory :trainer do
    gym
    user { create(:spree_user) }
  end
end
