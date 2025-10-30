# frozen_string_literal: true

# Legacy migration — superseded by 20251001000001_create_core_domain.
# Do NOT create the sessions table here on fresh installs.
# If the table already exists from older installs, we can safely ensure indexes.

class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    # Als de tabel nog niet bestaat: niets doen. De CoreDomain-migratie maakt 'm goed aan.
    unless table_exists?(:sessions)
      say "Skipping legacy CreateSessions; sessions will be created by CreateCoreDomain", true
      return
    end

    # Als de tabel al bestaat (oude install), kun je hier desnoods nog 'veilige' indexen bijzetten.
    add_index :sessions, %i[gym_id starts_at]        if column_exists?(:sessions, :gym_id) &&
                                                        !index_exists?(:sessions, %i[gym_id starts_at])
    add_index :sessions, %i[class_type_id starts_at] if column_exists?(:sessions, :class_type_id) &&
                                                        !index_exists?(:sessions, %i[class_type_id starts_at])
  end
end
