FactoryBot.define do
  factory :booking do
    gym { session.class_type.gym }
    user { create(:spree_user) }
    session
    status { :confirmed }
  end
end
