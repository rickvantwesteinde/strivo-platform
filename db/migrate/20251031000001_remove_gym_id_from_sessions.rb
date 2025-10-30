# frozen_string_literal: true

class RemoveGymIdFromSessions < ActiveRecord::Migration[8.0]
  def change
    # Remove composite index first
    remove_index :sessions, name: "index_sessions_on_gym_id_and_starts_at" if index_exists?(:sessions, %i[gym_id starts_at])
    remove_index :sessions, :gym_id if index_exists?(:sessions, :gym_id)

    remove_reference :sessions, :gym, foreign_key: true if column_exists?(:sessions, :gym_id)
  end
end
