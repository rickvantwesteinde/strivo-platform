class AddReasonToCreditLedgers < ActiveRecord::Migration[8.0]
  def change
    return unless table_exists?(:credit_ledgers)

    add_column :credit_ledgers, :reason, :integer, default: 0, null: false unless column_exists?(:credit_ledgers, :reason)
  end
end
