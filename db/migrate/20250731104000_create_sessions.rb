# frozen_string_literal: true

# Legacy migration — superseded by 20251001000001_create_core_domain.
# Do NOT create the sessions table here on fresh installs.

class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    # Als de tabel niet bestaat, niets doen (CoreDomain maakt 'm correct aan)
    unless table_exists?(:sessions)
      say "Skipping legacy CreateSessions; sessions will be created by CreateCoreDomain", true
      return
    end

    # Bestond :sessions al? Dan alleen veilige indexen bijzetten als de kolommen bestaan.
    add_index :sessions, %i[gym_id starts_at], name: "index_sessions_on_gym_and_starts_at" \
      if column_exists?(:sessions, :gym_id) && column_exists?(:sessions, :starts_at) && !index_exists?(:sessions, %i[gym_id starts_at], name: "index_sessions_on_gym_and_starts_at")

    add_index :sessions, %i[class_type_id starts_at], name: "index_sessions_on_class_type_and_starts_at" \
      if column_exists?(:sessions, :class_type_id) && column_exists?(:sessions, :starts_at) && !index_exists?(:sessions, %i[class_type_id starts_at], name: "index_sessions_on_class_type_and_starts_at")
  end
end