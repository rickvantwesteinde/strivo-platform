# frozen_string_literal: true

class AddGymRefToSessionsSafe < ActiveRecord::Migration[8.0]
  def up
    # Add the column if it's missing
    unless column_exists?(:sessions, :gym_id)
      add_reference :sessions, :gym, foreign_key: true, index: false
    end

    # Ensure simple index exists
    unless index_exists?(:sessions, :gym_id)
      add_index :sessions, :gym_id
    end

    # Ensure composite index exists if starts_at is present
    if column_exists?(:sessions, :starts_at) && !index_exists?(:sessions, %i[gym_id starts_at])
      add_index :sessions, %i[gym_id starts_at]
    end
  end

  def down
    remove_index :sessions, column: %i[gym_id starts_at] if index_exists?(:sessions, %i[gym_id starts_at])
    remove_index :sessions, :gym_id if index_exists?(:sessions, :gym_id)

    # Only remove the reference if it exists
    remove_reference :sessions, :gym, foreign_key: true if column_exists?(:sessions, :gym_id)
  end
end
