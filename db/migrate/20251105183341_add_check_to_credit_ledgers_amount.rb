class AddCheckToCreditLedgersAmount < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :credit_ledgers, "amount <> 0", name: "credit_ledgers_amount_nonzero"
  end
end
