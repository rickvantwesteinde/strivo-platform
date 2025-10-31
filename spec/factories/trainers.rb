# spec/factories/trainers.rb
FactoryBot.define do
  factory :trainer do
    gym # ← korter en werkt hetzelfde
    user factory: :spree_user # ← of: user { create(:spree_user) }

    trait :with_bio do
      bio { "Certified yoga instructor with 5 years experience" }
    end
  end
end