# spec/factories/sessions.rb
FactoryBot.define do
  factory :session do
    class_type
    trainer
    starts_at { 1.hour.from_now }
    duration_minutes { 60 }  # Required!
    capacity { 14 }
    cancellation_cutoff_hours { 6 }

    trait :in_one_hour do
      starts_at { 1.hour.from_now }
    end

    trait :in_two_hours do
      starts_at { 2.hours.from_now }
    end
  end
end