class CreateCreditLedgers < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_ledgers do |t|
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :gym, null: false, foreign_key: true
      t.references :booking, foreign_key: true
      t.integer :amount, null: false
      t.integer :reason, null: false, default: 0
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :credit_ledgers, [:user_id, :gym_id]
  end
end
