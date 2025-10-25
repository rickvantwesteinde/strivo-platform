# frozen_string_literal: true

class CreateCoreDomain < ActiveRecord::Migration[8.0]
  def change
    # Gyms
    create_table :gyms, if_not_exists: true do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.timestamps
      t.index :slug, unique: true
    end

    # Class types
    create_table :class_types, if_not_exists: true do |t|
      t.references :gym, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :default_capacity, null: false, default: 14
      t.timestamps
      t.index %i[gym_id name], unique: true
    end

    # Trainers (user scoped to gym)
    create_table :trainers, if_not_exists: true do |t|
      t.references :gym, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.timestamps
      t.index %i[gym_id user_id], unique: true
    end

    # Policies
    create_table :policies, if_not_exists: true do |t|
      t.references :gym, null: false, foreign_key: true
      t.integer :cancel_cutoff_hours, null: false, default: 6
      t.integer :rollover_limit, null: false, default: 0
      t.integer :max_active_daily_bookings, null: false, default: 1
      t.timestamps
    end

    # Subscription plans
    create_table :subscription_plans, if_not_exists: true do |t|
      t.references :gym, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :per_week, null: false, default: 0
      t.integer :price_cents, null: false, default: 0
      t.boolean :unlimited, null: false, default: false
      t.string :stripe_price_id
      t.timestamps
      t.index %i[gym_id name], unique: true
    end

    # Subscriptions
    create_table :subscriptions, if_not_exists: true do |t|
      t.references :gym, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :subscription_plan, null: false, foreign_key: true
      t.date :starts_on, null: false
      t.integer :status, null: false, default: 0
      t.datetime :ended_at
      t.timestamps
      t.index %i[user_id subscription_plan_id status], name: 'index_active_subscription_by_user_and_plan'
    end

    # Sessions
    create_table :sessions, if_not_exists: true do |t|
      t.references :class_type, null: false, foreign_key: true
      t.references :trainer, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.integer :duration_minutes, null: false
      t.integer :capacity, null: false, default: 14
      t.timestamps
      t.index %i[class_type_id starts_at]
    end

    # Credit ledgers
    create_table :credit_ledgers, if_not_exists: true do |t|
      t.references :gym, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.integer :amount, null: false
      t.integer :reason, null: false, default: 0
      t.references :booking, foreign_key: true
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
      t.index :created_at
    end

    # Bookings
    create_table :bookings, if_not_exists: true do |t|
      t.references :gym, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :session, null: false, foreign_key: true
      t.references :subscription_plan, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :used_credits, null: false, default: 0
      t.datetime :canceled_at
      t.boolean :no_show, null: false, default: false
      t.timestamps
      t.index %i[session_id user_id], unique: true
      t.index :status
    end

    # Waitlist entries
    create_table :waitlist_entries, if_not_exists: true do |t|
      t.references :session, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.integer :position, null: false
      t.timestamps
      t.index %i[session_id position], unique: true
      t.index %i[session_id user_id], unique: true
    end
  end
end
