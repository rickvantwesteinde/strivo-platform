# frozen_string_literal: true

class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    # Skip if the table exists
    return if table_exists?(:bookings)

    create_table :bookings, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :session, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :canceled_at
      t.timestamps
    end

    add_index :bookings, [:user_id, :session_id], unique: true unless index_exists?(:bookings, [:user_id, :session_id], unique: true)
  end
end
