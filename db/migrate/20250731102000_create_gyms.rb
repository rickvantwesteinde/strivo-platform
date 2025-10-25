class CreateGyms < ActiveRecord::Migration[8.0]
  def change
    create_table :gyms do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :address

      t.timestamps
    end

    add_index :gyms, :slug, unique: true
  end
end
