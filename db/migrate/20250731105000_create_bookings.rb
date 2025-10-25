class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :session, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :canceled_at

      t.timestamps
    end

    add_index :bookings, [:user_id, :session_id], unique: true
  end
end
