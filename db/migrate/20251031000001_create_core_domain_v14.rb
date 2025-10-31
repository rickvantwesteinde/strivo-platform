# frozen_string_literal: true

class CreateCoreDomainV14 < ActiveRecord::Migration[8.0]
  def change
    # Policies table
    unless table_exists?(:policies)
      create_table :policies do |t|
        t.references :gym, null: false, foreign_key: true
        t.integer :cancel_cutoff_hours, null: false, default: 6
        t.integer :rollover_limit, null: false, default: 2
        t.integer :max_active_daily_bookings, null: false, default: 1
        t.timestamps
      end
    end

    # Trainers table
    unless table_exists?(:trainers)
      create_table :trainers do |t|
        t.references :gym, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: { to_table: :spree_users }
        t.string :bio
        t.timestamps
      end
      add_index :trainers, [:gym_id, :user_id], unique: true unless index_exists?(:trainers, [:gym_id, :user_id], unique: true)
    end

    # Subscription Plans table
    unless table_exists?(:subscription_plans)
      create_table :subscription_plans do |t|
        t.references :gym, null: false, foreign_key: true
        t.string :name, null: false
        t.integer :per_week, null: false, default: 0
        t.boolean :unlimited, null: false, default: false
        t.integer :price_cents, null: false, default: 0
        t.string :stripe_price_id
        t.timestamps
      end
      add_index :subscription_plans, [:gym_id, :name], unique: true unless index_exists?(:subscription_plans, [:gym_id, :name], unique: true)
    end

    # Subscriptions table
    unless table_exists?(:subscriptions)
      create_table :subscriptions do |t|
        t.references :gym, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: { to_table: :spree_users }
        t.references :subscription_plan, null: false, foreign_key: true
        t.date :starts_on, null: false
        t.integer :status, null: false, default: 0
        t.datetime :ended_at
        t.timestamps
      end
      add_index :subscriptions, [:user_id, :gym_id, :status] unless index_exists?(:subscriptions, [:user_id, :gym_id, :status])
    end

    # Update sessions table to add trainer_id if it doesn't exist
    if table_exists?(:sessions)
      unless column_exists?(:sessions, :trainer_id)
        add_reference :sessions, :trainer, foreign_key: true
      end
      
      # Add duration_minutes if missing
      unless column_exists?(:sessions, :duration_minutes)
        add_column :sessions, :duration_minutes, :integer, null: false, default: 60
      end
    end

    # Update bookings table to add new required columns
    if table_exists?(:bookings)
      unless column_exists?(:bookings, :gym_id)
        add_reference :bookings, :gym, null: false, foreign_key: true
      end
      
      unless column_exists?(:bookings, :subscription_plan_id)
        add_reference :bookings, :subscription_plan, foreign_key: true
      end
      
      unless column_exists?(:bookings, :used_credits)
        add_column :bookings, :used_credits, :integer, null: false, default: 0
      end
      
      unless column_exists?(:bookings, :no_show)
        add_column :bookings, :no_show, :boolean, null: false, default: false
      end
      
      # Fix unique index - should be session_id, user_id not user_id, session_id
      if index_exists?(:bookings, [:user_id, :session_id], unique: true)
        remove_index :bookings, [:user_id, :session_id]
      end
      add_index :bookings, [:session_id, :user_id], unique: true unless index_exists?(:bookings, [:session_id, :user_id], unique: true)
    end

    # Update credit_ledgers table
    if table_exists?(:credit_ledgers)
      # Ensure gym_id comes first (reorder if needed by recreating index)
      if index_exists?(:credit_ledgers, [:user_id, :gym_id])
        remove_index :credit_ledgers, [:user_id, :gym_id]
      end
      add_index :credit_ledgers, [:gym_id, :user_id] unless index_exists?(:credit_ledgers, [:gym_id, :user_id])
      
      # Add GIN index on metadata jsonb column if not exists
      add_index :credit_ledgers, :metadata, using: :gin unless index_exists?(:credit_ledgers, :metadata)
    end

    # Waitlist Entries table
    unless table_exists?(:waitlist_entries)
      create_table :waitlist_entries do |t|
        t.references :session, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: { to_table: :spree_users }
        t.integer :position, null: false
        t.timestamps
      end
      add_index :waitlist_entries, [:session_id, :user_id], unique: true unless index_exists?(:waitlist_entries, [:session_id, :user_id], unique: true)
      add_index :waitlist_entries, [:session_id, :position], unique: true unless index_exists?(:waitlist_entries, [:session_id, :position], unique: true)
    end
  end
end
