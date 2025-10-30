# frozen_string_literal: true

# Legacy migration — superseded by 20251001000001_create_core_domain.
# Do NOT create the sessions table here on fresh installs.
# If the table already exists from older installs, we only ensure safe indexes.

class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    # Als de tabel nog niet bestaat: niets doen. CoreDomain maakt 'm correct aan.
    unless table_exists?(:sessions)
      say "Skipping legacy CreateSessions; sessions will be created by CreateCoreDomain", true
      return
    end

    # Bestond :sessions al? Dan alleen veilige indexen bijzetten als de kolommen bestaan.
    add_index :sessions, %i[gym_id starts_at]        if column_exists?(:sessions, :gym_id) &&
                                                        !index_exists?(:sessions, %i[gym_id starts_at])
    add_index :sessions, %i[class_type_id starts_at] if column_exists?(:sessions, :class_type_id) &&
                                                        !index_exists?(:sessions, %i[class_type_id starts_at])
  end
end
