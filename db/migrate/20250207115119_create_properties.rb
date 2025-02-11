class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_enum :property_field_type, %w[text number single_select multi_select]

    create_table :properties do |t|
      t.references :tenant, foreign_key: true, null: false
      t.string :name, null: false
      t.enum :field_type, enum_type: "property_field_type", null: false
      t.jsonb :options, default: {}
      t.timestamps
    end

    add_index :properties, [ :tenant_id, :name ], unique: true
  end
end
