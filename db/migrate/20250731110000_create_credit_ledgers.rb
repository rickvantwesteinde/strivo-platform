# frozen_string_literal: true

class CreateCreditLedgers < ActiveRecord::Migration[8.0]
  def change
    # Skip if the table exists
    return if table_exists?(:credit_ledgers)

    create_table :credit_ledgers, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :gym, null: false, foreign_key: true
      t.references :booking, foreign_key: true
      t.integer :amount, null: false
      t.integer :reason, null: false, default: 0
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end

    add_index :credit_ledgers, [:user_id, :gym_id] unless index_exists?(:credit_ledgers, [:user_id, :gym_id])
    # Uncomment the line below if you need a GIN index on metadata in a production environment
    # add_index :credit_ledgers, :metadata, using: :gin unless index_exists?(:credit_ledgers, :metadata)
  end
end
