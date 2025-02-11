class CreatePropertyValueItems < ActiveRecord::Migration[8.0]
  def change
    create_table :property_value_items do |t|
      t.references :property_value, foreign_key: true, null: false
      t.string :value, null: false
      t.timestamps
    end

    add_index :property_value_items, [ :property_value_id, :value ], unique: true
  end
end
