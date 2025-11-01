# == Sessions ==
create_table :sessions, if_not_exists: true do |t|
  t.references :class_type, null: false, foreign_key: true
  t.references :trainer,    null: false, foreign_key: true
  t.datetime :starts_at, null: false
  t.integer  :duration_minutes, null: false, default: 60
  t.integer  :capacity,         null: false, default: 14
  t.timestamps
end

# Indexen alleen toevoegen als kolommen bestaan (safe/herhaalbaar)
if column_exists?(:sessions, :class_type_id) && column_exists?(:sessions, :starts_at)
  add_index :sessions,
            %i[class_type_id starts_at],
            unique: false,
            name: "index_sessions_on_class_type_id_and_starts_at"
            unless index_exists?(:sessions, %i[class_type_id starts_at], name: "index_sessions_on_class_type_id_and_starts_at")
end