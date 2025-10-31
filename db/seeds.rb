# frozen_string_literal: true

Spree::Core::Engine.load_seed if defined?(Spree::Core)

ActiveRecord::Base.transaction do
  # Create X Gym
  gym = Gym.find_or_create_by!(slug: 'x-gym') do |g|
    g.name = 'X Gym'
    g.address = 'Amsterdam'
  end

  # Create policy
  policy = gym.policies.first_or_create!(
    cancel_cutoff_hours: 6,
    rollover_limit: 2,
    max_active_daily_bookings: 1
  )

  # Create class types
  class_types_data = [
    { name: 'Kickboksen', description: 'Kickboksen training', capacity: 14, duration: 60 },
    { name: 'Fitboksen', description: 'Boksen voor conditie', capacity: 14, duration: 60 },
    { name: 'Kinderboksen', description: 'Kids training', capacity: 10, duration: 45 },
    { name: 'Familieboksen', description: 'Gezinsles', capacity: 12, duration: 60 },
    { name: 'HIIT', description: 'High Intensity Interval Training', capacity: 16, duration: 45 }
  ]

  class_types = class_types_data.map do |attrs|
    gym.class_types.find_or_create_by!(name: attrs[:name]) do |ct|
      ct.description = attrs[:description]
      ct.default_capacity = attrs[:capacity]
      ct.default_duration_minutes = attrs[:duration]
      ct.default_cancellation_cutoff_hours = 6
    end
  end

  # Create subscription plans
  [
    { name: 'Basic', per_week: 2, price_cents: 4999, unlimited: false },
    { name: 'Plus', per_week: 4, price_cents: 7999, unlimited: false },
    { name: 'Pro', per_week: 6, price_cents: 9999, unlimited: false },
    { name: 'Unlimited', per_week: 0, price_cents: 12999, unlimited: true }
  ].each do |attrs|
    gym.subscription_plans.find_or_create_by!(name: attrs[:name]) do |plan|
      plan.per_week = attrs[:per_week]
      plan.price_cents = attrs[:price_cents]
      plan.unlimited = attrs[:unlimited]
    end
  end

  # Only in development: create trainers, users, sessions
  if Rails.env.development?
    password = 'Password1!'

    # Create trainers
    trainer_emails = %w[trainer1@xgym.test trainer2@xgym.test trainer3@xgym.test]
    trainers = trainer_emails.map do |email|
      u = Spree::User.find_or_create_by!(email: email) do |usr|
        usr.password = password
        usr.password_confirmation = password
      end
      gym.trainers.find_or_create_by!(user: u)
    end

    # Create demo user with credits
    demo_user = Spree::User.find_or_create_by!(email: 'user1@example.com') do |u|
      u.password = password
      u.password_confirmation = password
    end

    unless CreditLedger.where(user: demo_user, gym: gym, reason: :monthly_grant).exists?
      CreditLedger.create!(
        user: demo_user,
        gym: gym,
        amount: 10,
        reason: :monthly_grant,
        metadata: { month: Date.current.beginning_of_month.iso8601 }
      )
    end

    # Create member users
    members = (1..20).map do |i|
      email = format('member%02d@xgym.test', i)
      Spree::User.find_or_create_by!(email: email) do |u|
        u.password = password
        u.password_confirmation = password
      end
    end

    # Give first 10 members Basic plan subscriptions
    basic_plan = gym.subscription_plans.find_by(name: 'Basic')
    if basic_plan
      members.first(10).each do |member|
        Subscription.find_or_create_by!(
          user: member,
          subscription_plan: basic_plan,
          starts_on: Date.current.beginning_of_month
        ) do |sub|
          sub.gym = gym
          sub.status = :active
        end
      end
    end

    # Create 4 weeks of sessions
    start_date = Date.current.beginning_of_week(:monday)
    (0...28).each do |offset|
      date = start_date + offset.days
      class_types.each_with_index do |class_type, idx|
        starts_at = Time.zone.local(date.year, date.month, date.day, 9 + (idx * 2), 0, 0)
        trainer = trainers[idx % trainers.length]

        Session.find_or_create_by!(
          class_type: class_type,
          trainer: trainer,
          starts_at: starts_at
        ) do |session|
          session.duration_minutes = class_type.default_duration_minutes
          session.capacity = class_type.default_capacity
        end
      end
    end
  end
end

