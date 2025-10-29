# frozen_string_literal: true

# Fixed migration for creating the sessions table.
#
# This version ensures that the sessions table is only created when it does
# not already exist and that indexes are added only if the relevant
# columns are present. This prevents errors such as
# `PG::UndefinedColumn: ERROR: column "gym_id" does not exist` when
# running migrations multiple times (e.g. in CI environments).

class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    # Skip the migration entirely if the sessions table already exists.
    return if table_exists?(:sessions)

    create_table :sessions, if_not_exists: true do |t|
      t.references :class_type, null: false, foreign_key: true
      t.references :gym, null: false, foreign_key: true
      t.datetime   :starts_at, null: false
      t.integer    :duration_minutes, null: false, default: 60
      t.integer    :capacity, null: false, default: 12
      t.integer    :cancellation_cutoff_hours, null: false, default: 2
      t.string     :trainer_name
      t.timestamps
    end

    # Safely add indexes only if the columns exist and the index is missing
    if column_exists?(:sessions, :gym_id) && !index_exists?(:sessions, %i[gym_id starts_at])
      add_index :sessions, %i[gym_id starts_at]
    end
    if column_exists?(:sessions, :class_type_id) && !index_exists?(:sessions, %i[class_type_id starts_at])
      add_index :sessions, %i[class_type_id starts_at]
    end
  end
end
