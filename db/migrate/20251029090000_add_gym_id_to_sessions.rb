# frozen_string_literal: true

# Migration to ensure the sessions table has a gym_id column and index.
#
# This migration is idempotent: if the column or index already exists, it
# will not attempt to recreate them. This avoids errors in environments
# where the schema might already be partially applied, such as during CI.

class AddGymIdToSessions < ActiveRecord::Migration[8.0]
  def change
    # Add the gym_id column only if it doesn't already exist
    unless column_exists?(:sessions, :gym_id)
      add_reference :sessions, :gym, null: false, foreign_key: true
    end

    # Add the gym_id index only if it doesn't already exist
    unless index_exists?(:sessions, :gym_id)
      add_index :sessions, :gym_id
    end
  end
end
