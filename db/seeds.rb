
# frozen_string_literal: true

# db/seeds.rb
# Idempotente basisdata voor alle omgevingen.
# Deze seed kan veilig meerdere keren worden uitgevoerd.

Spree::Core::Engine.load_seed if defined?(Spree::Core)

password = 'Password1!'

# == Gebruikers ==
demo_user = Spree::User.find_or_create_by!(email: 'user1@example.com') do |u|
  u.password = password
  u.password_confirmation = password
end

trainer_user = Spree::User.find_or_create_by!(email: 'trainer@example.com') do |u|
  u.password = password
  u.password_confirmation = password
end

# == Gym ==
gym = Gym.find_or_create_by!(slug: 'demo-gym') do |g|
  g.name    = 'Demo Gym'
  g.address = 'Amsterdam'
end

# == Policy ==
gym.default_policy

# == Trainer ==
trainer = Trainer.find_or_create_by!(gym: gym, user: trainer_user)

# == Class Types ==
%w[HIIT Yoga].each do |name|
  ClassType.find_or_create_by!(gym: gym, name: name) do |ct|
    ct.default_capacity                  = 14
    ct.default_duration_minutes          = 60
    ct.default_cancellation_cutoff_hours = 6
  end
end

# == Sessions ==
# Let op: geen :gym-parameter meer; Session krijgt gym via class_type.gym
ClassType.where(gym: gym).find_each do |class_type|
  (1..4).each do |offset|
    start_time = offset.days.from_now.change(hour: 9 + offset, min: 0)

    Session.find_or_create_by!(
      class_type: class_type,
      trainer:    trainer,
      starts_at:  start_time
    ) do |s|
      s.capacity                  = class_type.default_capacity || 14
      s.duration_minutes          = class_type.default_duration_minutes || 60
      s.cancellation_cutoff_hours = class_type.default_cancellation_cutoff_hours || 6
    end
  end
end

# == Credits ==
unless CreditLedger.for_user_and_gym(user: demo_user, gym: gym).exists?
  CreditLedger.create!(
    user:   demo_user,
    gym:    gym,
    amount: 10,
    reason: :monthly_grant
  )
end

puts "✅ Seed completed successfully for #{gym.name}"