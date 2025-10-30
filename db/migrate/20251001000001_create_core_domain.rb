# frozen_string_literal: true

class CreateCoreDomain < ActiveRecord::Migration[8.0]
  def change
    # == Gyms ==
    create_table :gyms, if_not_exists: true do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :address
      t.timestamps
      t.index :slug, unique: true
    end

    # == Class Types ==
    create_table :class_types, if_not_exists: true do |t|
      t.references :gym, null: false, foreign_key: true
      t.string  :name, null: false
      t.text    :description
      t.integer :default_capacity, null: false, default: 14
      t.integer :default_duration_minutes
      t.integer :default_cancellation_cutoff_hours
      t.timestamps
      t.index %i[gym_id name], unique: true
    end

    # == Trainers (user scoped to gym) ==
    create_table :trainers, if_not_exists: true do |t|
      t.references :gym,  null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.string :bio
      t.timestamps
      t.index %i[gym_id user_id], unique: true
    end

    # == Policies ==
    create_table :policies, if_not_exists: true do |t|
      t.references :gym, null: false, foreign_key: true
      t.integer :cancel_cutoff_hours, null: false, default: 6
      t.integer :rollover_limit, null: false, default: 2
      t.integer :max_active_daily_bookings, null: false, default: 1
      t.timestamps
    end

    # == Subscription Plans ==
    create_table :subscription_plans, if_not_exists: true do |t|
      t.references :gym, null: false, foreign_key: true
      t.string  :name, null: false
      t.integer :per_week, null: false, default: 0
      t.boolean :unlimited, null: false, default: false
      t.integer :price_cents, null: false, default: 0
      t.string  :stripe_price_id
      t.timestamps
      t.index %i[gym_id name], unique: true
    end

    # == Subscriptions ==
    create_table :subscriptions, if_not_exists: true do |t|
      t.references :gym,  null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :subscription_plan, null: false, foreign_key: true
      t.date     :starts_on, null: false
      t.string   :status,    null: false, default: 'active'
      t.datetime :ended_at
      t.timestamps
      t.index %i[user_id gym_id status]
      t.index %i[user_id subscription_plan_id starts_on]
    end

    # == Sessions ==
    create_table :sessions, if_not_exists: true do |t|
      t.references :class_type, null: false, foreign_key: true
      # gym_id removed – gym is reachable via class_type → gym
      t.references :trainer,    null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.integer  :duration_minutes, null: false, default: 60
      t.integer  :capacity,         null: false, default: 14
      t.integer  :cancellation_cutoff_hours, null: false, default: 6
      t.timestamps

      # Index on gym_id removed – not needed
      t.index %i[class_type_id starts_at]
    end

    # == Bookings ==
    create_table :bookings, if_not_exists: true do |t|
      t.references :gym,     null: false, foreign_key: true
      t.references :user,    null: false, foreign_key: { to_table: :spree_users }
      t.references :session, null: false, foreign_key: true
      t.references :subscription_plan, foreign_key: true
      t.integer  :status,       null: false, default: 0   # enum { confirmed:0, canceled:1 }
      t.integer  :used_credits, null: false, default: 0
      t.datetime :canceled_at
      t.boolean  :no_show, null: false, default: false
      t.timestamps
      t.index %i[user_id session_id], unique: true
      t.index %i[gym_id status]
    end

    # == Credit Ledgers ==
    create_table :credit_ledgers, if_not_exists: true do |t|
      t.references :gym,  null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :booking, foreign_key: true
      t.integer :reason, null: false, default: 0
      t.integer :amount, null: false
      t.jsonb   :metadata, null: false, default: {}
      t.timestamps
      t.index %i[user_id gym_id]
      t.index :metadata, using: :gin
    end

    # == Waitlist Entries ==
    create_table :waitlist_entries, if_not_exists: true do |t|
      t.references :session, null: false, foreign_key: true
      t.references :user,    null: false, foreign_key: { to_table: :spree_users }
      t.timestamps
      t.index %i[session_id created_at]
      t.index %i[session_id user_id], unique: true
    end
  end
end
