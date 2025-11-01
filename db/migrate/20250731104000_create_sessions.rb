
# frozen_string_literal: true

# Legacy migration — superseded by 20251001000001_create_core_domain.
# Do NOT create the sessions table here on fresh installs.

class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    # Als :sessions niet bestaat, niets doen; CoreDomain maakt 'm aan.
    unless table_exists?(:sessions)
      say "Skipping legacy CreateSessions; sessions will be created by CreateCoreDomain", true
      return
    end

    # Alleen veilige index bijzetten op bestaande kolommen.
    if column_exists?(:sessions, :class_type_id) && column_exists?(:sessions, :starts_at)
      add_index :sessions,
                %i[class_type_id starts_at],
                name: "index_sessions_on_class_type_id_and_starts_at"
                unless index_exists?(:sessions, %i[class_type_id starts_at], name: "index_sessions_on_class_type_id_and_starts_at")
    end
  end
end