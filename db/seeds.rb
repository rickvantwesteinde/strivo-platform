# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Spree::Core::Engine.load_seed if defined?(Spree::Core)

password = 'Password1!'
demo_user = Spree::User.find_or_create_by!(email: 'user1@example.com') do |user|
  user.password = password
  user.password_confirmation = password
end

trainer_user = Spree::User.find_or_create_by!(email: 'trainer@example.com') do |user|
  user.password = password
  user.password_confirmation = password
end

gym = Gym.find_or_create_by!(slug: 'demo-gym') do |record|
  record.name = 'Demo Gym'
  record.address = 'Amsterdam'
end

gym.default_policy

trainer = Trainer.find_or_create_by!(gym:, user: trainer_user)

class_types = %w[HIIT Yoga]

class_types.each do |name|
  ClassType.find_or_create_by!(gym:, name:)
end

ClassType.where(gym:).find_each do |class_type|
  (1..4).each do |offset|
    start_time = offset.days.from_now.change(hour: 9 + offset, min: 0)
    Session.find_or_create_by!(class_type:, trainer:, starts_at: start_time) do |session|
      session.capacity = class_type.default_capacity
      session.duration_minutes = class_type.default_duration_minutes
    end
  end
end

unless CreditLedger.for_user_and_gym(user: demo_user, gym:).exists?
  CreditLedger.create!(user: demo_user, gym:, amount: 10, reason: :monthly_grant)
end
