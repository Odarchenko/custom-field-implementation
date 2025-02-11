# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_02_07_120256) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "property_field_type", ["text", "number", "single_select", "multi_select"]

  create_table "properties", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name", null: false
    t.enum "field_type", null: false, enum_type: "property_field_type"
    t.jsonb "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "name"], name: "index_properties_on_tenant_id_and_name", unique: true
    t.index ["tenant_id"], name: "index_properties_on_tenant_id"
  end

  create_table "property_value_items", force: :cascade do |t|
    t.bigint "property_value_id", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_value_id", "value"], name: "index_property_value_items_on_property_value_id_and_value", unique: true
    t.index ["property_value_id"], name: "index_property_value_items_on_property_value_id"
  end

  create_table "property_values", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "property_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_property_values_on_property_id"
    t.index ["user_id", "property_id"], name: "index_property_values_on_user_id_and_property_id", unique: true
    t.index ["user_id"], name: "index_property_values_on_user_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "properties", "tenants"
  add_foreign_key "property_value_items", "property_values"
  add_foreign_key "property_values", "properties"
  add_foreign_key "property_values", "users"
  add_foreign_key "users", "tenants"
end
