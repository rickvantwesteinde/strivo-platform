# frozen_string_literal: true

class CreateClassTypes < ActiveRecord::Migration[8.0]
  def change
    # Skip if the table exists
    return if table_exists?(:class_types)

    create_table :class_types, if_not_exists: true do |t|
      t.references :gym, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :default_duration_minutes, null: false, default: 60
      t.integer :default_capacity, null: false, default: 12
      t.integer :default_cancellation_cutoff_hours, null: false, default: 2
      t.timestamps
    end

    add_index :class_types, [:gym_id, :name], unique: true unless index_exists?(:class_types, [:gym_id, :name], unique: true)
  end
end
