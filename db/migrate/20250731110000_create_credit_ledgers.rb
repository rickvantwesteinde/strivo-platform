class CreateCreditLedgers < ActiveRecord::Migration[7.1]
  def change
    create_table :credit_ledgers do |t|
      t.references :user, null: false, foreign_key: { to_table: :spree_users }
      t.references :gym,  null: false, foreign_key: true
      t.integer :amount,  null: false
      t.integer :reason,  null: false, default: 0
      t.jsonb :metadata,  null: false, default: {}

      t.timestamps
    end

    add_index :credit_ledgers, [:user_id, :gym_id, :created_at]
    add_index :credit_ledgers, :reason
    add_index :credit_ledgers, :metadata, using: :gin
  end
end
