# frozen_string_literal: true

class AddGymRefToSessionsSafe < ActiveRecord::Migration[8.0]
  def up
    # Ensure the column exists
    unless column_exists?(:sessions, :gym_id)
      add_reference :sessions, :gym, foreign_key: true, index: false # index added below
    end

    # Make sure the simple index exists (some code may expect it)
    unless index_exists?(:sessions, :gym_id)
      add_index :sessions, :gym_id
    end

    # If you use a composite index in queries, guard and add it too
    if column_exists?(:sessions, :starts_at) &&
       !index_exists?(:sessions, %i[gym_id starts_at])
      add_index :sessions, %i[gym_id starts_at]
    end
  end

  def down
    # Be conservative on down to avoid breaking other migrations
    remove_index :sessions, column: %i[gym_id starts_at] if index_exists?(:sessions, %i[gym_id starts_at])
    remove_index :sessions, :gym_id if index_exists?(:sessions, :gym_id)

    # Only remove the column if it’s not part of a foreign key graph you rely on
    if column_exists?(:sessions, :gym_id)
      remove_reference :sessions, :gym, foreign_key: true
    end
  end
end
