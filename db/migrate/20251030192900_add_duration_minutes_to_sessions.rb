class AddDurationMinutesToSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :sessions, :duration_minutes, :integer, default: 60, null: false
  end
end