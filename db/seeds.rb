Spree::Core::Engine.load_seed if defined?(Spree::Core)

ActiveRecord::Base.transaction do
  gym = Gym.find_or_create_by!(slug: "x-gym") do |g|
    g.name = "X Gym"
  end

  policy = gym.policy || gym.build_policy
  policy.update!(cancel_cutoff_hours: 6, rollover_limit: 2, max_active_daily_bookings: 1)

  class_types_data = [
    "Kickboksen",
    "Fitboksen",
    "Kinderboksen",
    "Familieboksen",
    "HIIT"
  ]

  class_types = class_types_data.map do |name|
    gym.class_types.find_or_create_by!(name:) do |class_type|
      class_type.default_capacity = 14
    end
  end

  trainer_emails = [
    "trainer1@xgym.test",
    "trainer2@xgym.test",
    "trainer3@xgym.test"
  ]

  trainers = trainer_emails.map do |email|
    user = Spree::User.find_or_create_by!(email:) do |u|
      u.password = "password"
      u.password_confirmation = "password"
    end

    gym.trainers.find_or_create_by!(user:)
  end

  plans = [
    { name: "Basic", per_week: 2, price_cents: 4999, unlimited: false },
    { name: "Plus", per_week: 4, price_cents: 7999, unlimited: false },
    { name: "Pro", per_week: 6, price_cents: 9999, unlimited: false },
    { name: "Unlimited", per_week: 0, price_cents: 12999, unlimited: true }
  ].map do |attrs|
    gym.subscription_plans.find_or_create_by!(name: attrs[:name]) do |plan|
      plan.per_week = attrs[:per_week]
      plan.price_cents = attrs[:price_cents]
      plan.unlimited = attrs[:unlimited]
    end
  end

  members = (1..20).map do |index|
    email = format("member%02d@xgym.test", index)
    Spree::User.find_or_create_by!(email:) do |user|
      user.password = "password"
      user.password_confirmation = "password"
    end
  end

  basic_plan = plans.find { |plan| plan.name == "Basic" }

  members.first(10).each do |member|
    Subscription.find_or_create_by!(user: member, plan: basic_plan, starts_on: Date.current.beginning_of_month) do |subscription|
      subscription.gym = gym
      subscription.status = :active
    end
  end

  start_date = Date.current.beginning_of_week(:monday)
  (0...28).each do |offset|
    date = start_date + offset.days
    class_types.each_with_index do |class_type, index|
      starts_at = Time.zone.local(date.year, date.month, date.day, 9 + (index * 2), 0, 0)
      trainer = trainers[index % trainers.length]

      session = class_type.sessions.find_or_initialize_by(starts_at: starts_at)
      session.trainer = trainer
      session.duration_minutes = 60
      session.capacity = class_type.capacity
      session.save!
    end
  end
end
