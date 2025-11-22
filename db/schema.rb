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

ActiveRecord::Schema[8.0].define(version: 2025_11_21_095636) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "events_id", null: false
    t.bigint "users_id", null: false
    t.index ["events_id"], name: "index_comments_on_events_id"
    t.index ["users_id"], name: "index_comments_on_users_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "location", null: false
    t.boolean "published", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "users_id", null: false
    t.bigint "categories_id", null: false
    t.index ["categories_id"], name: "index_events_on_categories_id"
    t.index ["users_id"], name: "index_events_on_users_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.decimal "price", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "events_id", null: false
    t.index ["events_id"], name: "index_tickets_on_events_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.boolean "is_admin", default: false, null: false
  end

  add_foreign_key "comments", "events", column: "events_id"
  add_foreign_key "comments", "users", column: "users_id"
  add_foreign_key "events", "categories", column: "categories_id"
  add_foreign_key "events", "users", column: "users_id"
  add_foreign_key "tickets", "events", column: "events_id"
end
