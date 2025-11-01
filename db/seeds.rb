# frozen_string_literal: true
Spree::Core::Engine.load_seed if defined?(Spree::Core)

password = 'Password1!'

demo_user = Spree::User.find_or_create_by!(email: 'user1@example.com') { |u| u.password = u.password_confirmation = password }
trainer_user = Spree::User.find_or_create_by!(email: 'trainer@example.com') { |u| u.password = u.password_confirmation = password }

gym = Gym.find_or_create_by!(slug: 'demo-gym') { |g| g.name = 'Demo Gym'; g.address = 'Amsterdam' }
gym.default_policy

trainer = Trainer.find_or_create_by!(gym: gym, user: trainer_user)

%w[HIIT Yoga].each do |name|
  ClassType.find_or_create_by!(gym: gym, name: name) do |ct|
    ct.default_capacity                  = 14
    ct.default_duration_minutes          = 60
    ct.default_cancellation_cutoff_hours = 6
  end
end

ClassType.where(gym: gym).find_each do |class_type|
  (1..4).each do |offset|
    start_time = offset.days.from_now.change(hour: 9 + offset, min: 0)
    Session.find_or_create_by!(class_type: class_type, trainer: trainer, gym: gym, starts_at: start_time) do |s|
      s.capacity                  = class_type.default_capacity || 14
      s.duration_minutes          = class_type.default_duration_minutes || 60
      s.cancellation_cutoff_hours = class_type.default_cancellation_cutoff_hours || 6
    end
  end
end

unless CreditLedger.for_user_and_gym(user: demo_user, gym: gym).exists?
  CreditLedger.create!(user: demo_user, gym: gym, amount: 10, reason: :monthly_grant)
end

puts "✅ Seed completed successfully for #{gym.name}"