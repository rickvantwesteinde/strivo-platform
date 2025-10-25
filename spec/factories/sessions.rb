FactoryBot.define do
  factory :session do
    association :class_type
    trainer { create(:trainer, gym: class_type.gym) }
    starts_at { Time.zone.now.change(min: 0) + 2.days }
    duration_minutes { 60 }
    capacity { class_type.default_capacity }
  end
end
