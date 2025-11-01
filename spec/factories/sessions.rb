# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    association :class_type
    # trainer en gym worden consistent met class_type gezet
    starts_at { 2.days.from_now.change(hour: 10, min: 0) }
    duration_minutes { 60 }
    capacity { 14 }
    cancellation_cutoff_hours { 6 }

    # Koppel trainer én gym op dezelfde gym als class_type
    after(:build) do |session|
      session.gym ||= session.class_type&.gym || build(:gym)
      session.trainer ||= build(:trainer, gym: session.gym)
    end
  end
end