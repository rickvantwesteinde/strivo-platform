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

def seed_user(email, password)
  Spree::User.find_or_create_by!(email:) do |user|
    user.password = password
    user.password_confirmation = password
  end
end

def seed_gym(slug, name:, address: nil)
  Gym.find_or_create_by!(slug:) do |record|
    record.name = name
    record.address = address
  end
end

def seed_class_types(gym, definitions)
  definitions.each do |attrs|
    ClassType.find_or_create_by!(gym:, name: attrs[:name]) do |class_type|
      class_type.description = attrs[:description]
    end
  end
end

def seed_sessions_for_gym(gym)
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
end

def ensure_membership(user:, gym:, **attributes)
  Membership.find_or_initialize_by(user:, gym:, starts_on: attributes.fetch(:starts_on)).tap do |membership|
    membership.assign_attributes(attributes)
    membership.save!
  end
end

demo_user = seed_user('user1@example.com', password)
demo_gym = seed_gym('demo-gym', name: 'Demo Gym', address: 'Amsterdam')

seed_class_types(demo_gym, [
  { name: 'HIIT', description: 'Intensieve interval training.' },
  { name: 'Yoga Flow', description: 'Vloeiende yoga sessie voor alle niveaus.' }
])

seed_sessions_for_gym(demo_gym)

ensure_membership(
  user: demo_user,
  gym: demo_gym,
  plan_type: :credit,
  credits_per_week: 3,
  rollover_limit: 10,
  starts_on: Date.new(Date.current.year, 1, 1)
)

x_gym = seed_gym('x-gym', name: 'X Gym', address: 'Rotterdam')

seed_class_types(x_gym, [
  { name: 'Strivo Strength', description: 'Krachttraining in kleine groepen.' },
  { name: 'Mobility Basics', description: 'Mobiliteit en herstel.' }
])

seed_sessions_for_gym(x_gym)

credit_user = seed_user('credit-member@example.com', password)
unlimited_user = seed_user('unlimited-member@example.com', password)

ensure_membership(
  user: credit_user,
  gym: x_gym,
  plan_type: :credit,
  credits_per_week: 4,
  rollover_limit: 12,
  starts_on: Date.new(Date.current.year, Date.current.month, 1)
)

ensure_membership(
  user: unlimited_user,
  gym: x_gym,
  plan_type: :unlimited,
  daily_soft_cap: 2,
  starts_on: Date.new(Date.current.year, Date.current.month, 1)
)
