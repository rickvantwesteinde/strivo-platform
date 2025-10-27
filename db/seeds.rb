# db/seeds.rb

# Laad Spree basis-seeds (payment methods, tax rates, etc.) indien aanwezig
Spree::Core::Engine.load_seed if defined?(Spree::Core)

ActiveRecord::Base.transaction do
  # ---- Gym + Policy (basis, safe for production) ----
  gym = Gym.find_or_create_by!(slug: 'x-gym') do |g|
    g.name = 'X Gym'
    g.address = 'Amsterdam' rescue nil
  end

  policy = gym.policy || gym.build_policy
  # Core policy-afspraken
  policy.update!(
    cancel_cutoff_hours: 6,
    rollover_limit: 2,
    max_active_daily_bookings: 1
  )

  # ---- Class Types (basis) ----
  class_types_data = [
    { name: 'Kickboksen',    description: 'Kickboksen training' },
    { name: 'Fitboksen',     description: 'Boksen voor conditie' },
    { name: 'Kinderboksen',  description: 'Kids training' },
    { name: 'Familieboksen', description: 'Gezinsles' },
    { name: 'HIIT',          description: 'High Intensity Interval Training' }
  ]

  class_types = class_types_data.map do |attrs|
    gym.class_types.find_or_create_by!(name: attrs[:name]) do |ct|
      ct.description = attrs[:description] rescue nil
      ct.default_capacity = 14 rescue nil
      ct.default_duration_minutes = 60 rescue nil
      ct.default_cancellation_cutoff_hours = 6 rescue nil
    end
  end

  # ---- Subscription Plans (basis) ----
  [
    { name: 'Basic',     per_week: 2, price_cents:  4999, unlimited: false },
    { name: 'Plus',      per_week: 4, price_cents:  7999, unlimited: false },
    { name: 'Pro',       per_week: 6, price_cents:  9999, unlimited: false },
    { name: 'Unlimited', per_week: 0, price_cents: 12999, unlimited: true  }
  ].each do |attrs|
    gym.subscription_plans.find_or_create_by!(name: attrs[:name]) do |plan|
      plan.per_week    = attrs[:per_week]
      plan.price_cents = attrs[:price_cents] rescue nil
      plan.unlimited   = attrs[:unlimited]
    end
  end

  # ---- Alleen in ontwikkeling: trainers, demo-users, sessions, credits ----
  if Rails.env.development?
    password = 'Password1!'

    # Trainers (als User + Trainer-record)
    trainer_emails = %w[trainer1@xgym.test trainer2@xgym.test trainer3@xgym.test]
    trainers = trainer_emails.map do |email|
      u = Spree::User.find_or_create_by!(email: email) do |usr|
        usr.password = password
        usr.password_confirmation = password
      end
      gym.trainers.find_or_create_by!(user: u)
    end

    # Demo member user + startcredits
    demo_user = Spree::User.find_or_create_by!(email: 'user1@example.com') do |u|
      u.password = password
      u.password_confirmation = password
    end

    CreditLedger.create!(user: demo_user, gym: gym, amount: 10, reason: :monthly_grant) \
      unless CreditLedger.where(user: demo_user, gym: gym, reason: :monthly_grant).exists?

    # 20 testleden (optioneel)
    members = (1..20).map do |i|
      email = format('member%02d@xgym.test', i)
      Spree::User.find_or_create_by!(email: email) do |u|
        u.password = password
        u.password_confirmation = password
      end
    end

    # Koppel 10 leden aan Basic plan
    basic_plan = gym.subscription_plans.find_by(name: 'Basic')
    if basic_plan
      members.first(10).each do |member|
        Subscription.find_or_create_by!(user: member, plan: basic_plan, starts_on: Date.current.beginning_of_month) do |sub|
          sub.gym = gym
          sub.status = :active
        end
      end
    end

    # 4 weken rooster genereren
    start_date = Date.current.beginning_of_week(:monday)
    (0...28).each do |offset|
      date = start_date + offset.days
      class_types.each_with_index do |class_type, idx|
        starts_at = Time.zone.local(date.year, date.month, date.day, 9 + (idx * 2), 0, 0)

        session = Session.find_or_initialize_by(class_type: class_type, gym: gym, starts_at: starts_at)
        session.duration_minutes = class_type.try(:default_duration_minutes) || 60
        session.capacity = class_type.try(:default_capacity) || 14
        session.cancellation_cutoff_hours = class_type.try(:default_cancellation_cutoff_hours) || 6 rescue nil
        # trainer-koppeling indien model/kolom bestaat
        if session.respond_to?(:trainer) && trainers.present?
          session.trainer = trainers[idx % trainers.length]
        end
        session.save!
      end
    end
  end
end