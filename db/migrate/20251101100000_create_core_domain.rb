class CreateCoreDomain < ActiveRecord::Migration[8.0]
  def change
    create_table :gyms do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :address
      t.timestamps
      t.index :slug, unique: true
    end

    create_table :policies do |t|
      t.references :gym, null: false, foreign_key: true
      t.integer :cancel_cutoff_hours, null: false, default: 6
      t.integer :rollover_limit, null: false, default: 2
      t.integer :max_active_daily_bookings, null: false, default: 1
      t.timestamps
    end

    create_table :class_types do |t|
      t.references :gym, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :default_capacity, null: false, default: 14
      t.integer :default_duration_minutes, null: false, default: 60
      t.integer :default_cancellation_cutoff_hours, null: false, default: 6
      t.timestamps
      t.index %i[gym_id name], unique: true
    end

    create_table :trainers do |t|
      t.references :gym, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.timestamps
      t.index %i[gym_id user_id], unique: true
    end

    create_table :subscription_plans do |t|
      t.references :gym, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :per_week, null: false, default: 0
      t.boolean :unlimited, null: false, default: false
      t.integer :price_cents, null: false, default: 0
      t.timestamps
      t.index %i[gym_id name], unique: true
    end

    create_table :subscriptions do |t|
      t.references :gym, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :subscription_plan, null: false, foreign_key: true
      t.date :starts_on, null: false
      t.string :status, null: false, default: 'active'
      t.timestamps
    end

    create_table :sessions do |t|
      t.references :class_type, null: false, foreign_key: true
      t.references :trainer, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.integer :duration_minutes, null: false, default: 60
      t.integer :capacity, null: false, default: 14
      t.timestamps
    end

    create_table :bookings do |t|
      t.references :gym, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :session, null: false, foreign_key: true
      t.references :subscription_plan, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :used_credits, null: false, default: 0
      t.datetime :canceled_at
      t.boolean :no_show, null: false, default: false
      t.timestamps
      t.index %i[user_id session_id], unique: true
    end

    create_table :credit_ledgers do |t|
      t.references :gym, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :booking, foreign_key: true
      t.integer :reason, null: false
      t.integer :amount, null: false
      t.jsonb :metadata, default: {}
      t.timestamps
      t.index %i[user_id gym_id]
    end

    create_table :waitlist_entries do |t|
      t.references :session, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.timestamps
      t.index %i[session_id user_id], unique: true
    end
  end
end
