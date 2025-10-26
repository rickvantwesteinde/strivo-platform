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

gym = Gym.find_or_create_by!(slug: 'demo-gym') do |record|
  record.name = 'Demo Gym'
  record.address = 'Amsterdam'
end

class_types = [
  { name: 'HIIT', description: 'Intensieve interval training.' },
  { name: 'Yoga Flow', description: 'Vloeiende yoga sessie voor alle niveaus.' }
]

class_types.each do |attrs|
  ClassType.find_or_create_by!(gym:, name: attrs[:name]) do |class_type|
    class_type.description = attrs[:description]
  end
end

ClassType.where(gym:).find_each do |class_type|
  (1..4).each do |offset|
    start_time = offset.days.from_now.change(hour: 9 + offset, min: 0)
    Session.find_or_create_by!(class_type:, gym:, starts_at: start_time) do |session|
      session.capacity = class_type.default_capacity
      session.duration_minutes = class_type.default_duration_minutes
      session.cancellation_cutoff_hours = class_type.default_cancellation_cutoff_hours
      session.trainer_name = ['Sam', 'Kim', 'Alex', 'Jamie'].sample
    end
  end
end

unless CreditLedger.where(user: demo_user, gym:).exists?
  CreditLedger.create!(user: demo_user, gym:, amount: 10, reason: :monthly_grant)
end
