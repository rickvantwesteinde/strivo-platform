# frozen_string_literal: true

class CreateGyms < ActiveRecord::Migration[8.0]
  def change
    # Skip this migration if the table already exists
    return if table_exists?(:gyms)

    create_table :gyms, if_not_exists: true do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :address
      t.timestamps
    end

    # Avoid duplicating the index
    add_index :gyms, :slug, unique: true unless index_exists?(:gyms, :slug, unique: true)
  end
end
