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

ActiveRecord::Schema[8.1].define(version: 2026_01_25_165614) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attendees", force: :cascade do |t|
    t.datetime "checked_in_at"
    t.datetime "created_at", null: false
    t.string "email"
    t.integer "event_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "order_id", null: false
    t.string "preferred_name"
    t.integer "ticket_id", null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_attendees_on_event_id"
    t.index ["order_id"], name: "index_attendees_on_order_id"
    t.index ["ticket_id"], name: "index_attendees_on_ticket_id"
    t.index ["token"], name: "index_attendees_on_token", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.date "end_date"
    t.string "location"
    t.boolean "publish"
    t.string "slug"
    t.date "start_date"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_events_on_slug"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.integer "quantity"
    t.integer "ticket_id", null: false
    t.decimal "unit_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["ticket_id"], name: "index_order_items_on_ticket_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "buyer_email"
    t.string "buyer_name"
    t.string "buyer_phone_no"
    t.datetime "created_at", null: false
    t.string "order_no"
    t.string "payment_provider"
    t.string "payment_reference"
    t.integer "status", default: 0
    t.decimal "total_cost", precision: 10, scale: 2
    t.integer "total_items"
    t.datetime "updated_at", null: false
    t.index ["order_no"], name: "index_orders_on_order_no", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_sale_date"
    t.integer "event_id", null: false
    t.integer "group_ticket_count"
    t.integer "max_ticket"
    t.integer "min_ticket"
    t.decimal "price", precision: 10, scale: 2
    t.integer "quantity"
    t.date "start_sale_date"
    t.boolean "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_tickets_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendees", "events"
  add_foreign_key "attendees", "orders"
  add_foreign_key "attendees", "tickets"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "tickets"
  add_foreign_key "sessions", "users"
  add_foreign_key "tickets", "events"
end
