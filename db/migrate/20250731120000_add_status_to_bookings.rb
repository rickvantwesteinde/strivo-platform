class AddStatusToBookings < ActiveRecord::Migration[8.0]
  def change
    return unless table_exists?(:bookings)

    add_column :bookings, :status, :integer, default: 0, null: false unless column_exists?(:bookings, :status)
  end
end
