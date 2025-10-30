# frozen_string_literal: true

class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    # Skip if the table exists
    return if table_exists?(:sessions)

    create_table :sessions, if_not_exists: true do |t|
      t.references :class_type, null: false, foreign_key: true
      t.references :gym, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.integer :duration_minutes, null: false, default: 60
      t.integer :capacity, null: false, default: 12
      t.integer :cancellation_cutoff_hours, null: false, default: 2
      t.string :trainer_name
      t.timestamps
    end

    add_index :sessions, [:gym_id, :starts_at] unless index_exists?(:sessions, [:gym_id, :starts_at])
    add_index :sessions, [:class_type_id, :starts_at] unless index_exists?(:sessions, [:class_type_id, :starts_at])
  end
end
