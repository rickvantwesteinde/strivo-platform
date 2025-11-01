# == Sessions ==
create_table :sessions, if_not_exists: true do |t|
  t.references :class_type, null: false, foreign_key: true
  t.references :gym,        null: false, foreign_key: true
  t.references :trainer,    null: false, foreign_key: true
  t.datetime :starts_at, null: false
  t.integer  :duration_minutes, null: false, default: 60
  t.integer  :capacity,         null: false, default: 14
  t.integer  :cancellation_cutoff_hours, null: false, default: 6
  t.timestamps
end

# Add indexes **after** table creation, guarded:
if column_exists?(:sessions, :gym_id) && column_exists?(:sessions, :starts_at)
  add_index :sessions, %i[gym_id starts_at] unless index_exists?(:sessions, %i[gym_id starts_at])
end
if column_exists?(:sessions, :class_type_id) && column_exists?(:sessions, :starts_at)
  add_index :sessions, %i[class_type_id starts_at] unless index_exists?(:sessions, %i[class_type_id starts_at])
end