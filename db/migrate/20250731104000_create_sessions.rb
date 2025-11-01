# db/migrate/20250731104000_create_sessions.rb
# Legacy migration — superseded by 20251001000001_create_core_domain.
# Do NOT create the sessions table here on fresh installs.

class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    unless table_exists?(:sessions)
      say "Skipping legacy CreateSessions; sessions will be created by CreateCoreDomain", true
      return
    end

    add_index :sessions, %i[gym_id starts_at]        if column_exists?(:sessions, :gym_id) &&
                                                        !index_exists?(:sessions, %i[gym_id starts_at])
    add_index :sessions, %i[class_type_id starts_at] if column_exists?(:sessions, :class_type_id) &&
                                                        !index_exists?(:sessions, %i[class_type_id starts_at])
  end
end