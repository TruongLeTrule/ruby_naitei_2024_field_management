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

ActiveRecord::Schema[7.0].define(version: 2024_07_28_090330) do
  create_table "favourite_fields", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "field_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_id"], name: "index_favourite_fields_on_field_id"
    t.index ["user_id"], name: "index_favourite_fields_on_user_id"
  end

  create_table "field_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.integer "ground"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fields", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.float "default_price"
    t.string "name"
    t.text "description"
    t.bigint "field_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "open_time"
    t.time "close_time"
    t.index ["field_type_id"], name: "index_fields_on_field_type_id"
    t.index ["name"], name: "index_fields_on_name"
  end

  create_table "order_fields", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.time "started_time"
    t.time "finished_time"
    t.date "date"
    t.float "final_price"
    t.integer "status"
    t.bigint "user_id", null: false
    t.bigint "field_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_id"], name: "index_order_fields_on_field_id"
    t.index ["user_id"], name: "index_order_fields_on_user_id"
  end

  create_table "ratings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "description"
    t.integer "rating"
    t.bigint "user_id", null: false
    t.bigint "field_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_id"], name: "index_ratings_on_field_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "reviews", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "description"
    t.bigint "user_id", null: false
    t.bigint "parent_review_id"
    t.bigint "parent_rating_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_rating_id"], name: "index_reviews_on_parent_rating_id"
    t.index ["parent_review_id"], name: "index_reviews_on_parent_review_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "unavailable_field_schedules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.time "started_time"
    t.time "finished_time"
    t.date "date"
    t.integer "status"
    t.bigint "field_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "order_field_id"
    t.index ["field_id"], name: "index_unavailable_field_schedules_on_field_id"
    t.index ["order_field_id"], name: "index_unavailable_field_schedules_on_order_field_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.float "money"
    t.string "password_digest"
    t.string "remember_digest"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.string "activation_digest"
    t.boolean "activated"
    t.datetime "activated_at"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "vouchers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.float "discount_price"
    t.float "discount_percent"
    t.integer "type"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_vouchers_on_user_id"
  end

  add_foreign_key "favourite_fields", "fields"
  add_foreign_key "favourite_fields", "users"
  add_foreign_key "fields", "field_types"
  add_foreign_key "order_fields", "fields"
  add_foreign_key "order_fields", "users"
  add_foreign_key "ratings", "fields"
  add_foreign_key "ratings", "users"
  add_foreign_key "reviews", "ratings", column: "parent_rating_id"
  add_foreign_key "reviews", "reviews", column: "parent_review_id"
  add_foreign_key "reviews", "users"
  add_foreign_key "unavailable_field_schedules", "fields"
  add_foreign_key "unavailable_field_schedules", "order_fields"
  add_foreign_key "vouchers", "users"
end
