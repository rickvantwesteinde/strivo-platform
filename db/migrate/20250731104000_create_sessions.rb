# frozen_string_literal: true

class EnsureSessionsHasGymId < ActiveRecord::Migration[8.0]
  def up
    return unless table_exists?(:sessions)

    unless column_exists?(:sessions, :gym_id)
      add_reference :sessions, :gym, null: true, foreign_key: true
    end

    unless index_exists?(:sessions, %i[gym_id starts_at]) || !column_exists?(:sessions, :starts_at)
      add_index :sessions, %i[gym_id starts_at]
    end
  end

  def down
    # no-op (we willen de kolom niet terugdraaien in oudere omgevingen)
  end
end