class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :gym, null: false, foreign_key: true
      t.integer :plan_type, null: false, default: 0
      t.decimal :credits_per_week, precision: 8, scale: 2
      t.integer :rollover_limit
      t.date :starts_on, null: false
      t.date :ends_on
      t.integer :daily_soft_cap
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :memberships, [:user_id, :gym_id, :starts_on]
  end
end
