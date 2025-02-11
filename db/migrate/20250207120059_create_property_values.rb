class CreatePropertyValues < ActiveRecord::Migration[8.0]
  def change
    create_table :property_values do |t|
      t.references :user, foreign_key: true, null: false
      t.references :property, foreign_key: true, null: false
      t.timestamps
    end

    add_index :property_values, [ :user_id, :property_id ], unique: true
  end
end
