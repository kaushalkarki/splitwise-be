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

ActiveRecord::Schema[7.1].define(version: 2024_08_22_122007) do
  create_table "expense_splits", force: :cascade do |t|
    t.integer "expense_id"
    t.integer "user_id"
    t.float "user_amount"
    t.boolean "paid", default: false
    t.boolean "owes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expenses", force: :cascade do |t|
    t.string "description", null: false
    t.float "amount"
    t.integer "group_id"
    t.integer "payer"
    t.date "transaction_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_subscriptions_on_group_id"
    t.index ["user_id"], name: "index_group_subscriptions_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settles", force: :cascade do |t|
    t.integer "sender", null: false
    t.integer "receiver", null: false
    t.integer "group_id"
    t.float "amount", null: false
    t.datetime "settle_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone", limit: 10
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "group_subscriptions", "groups"
  add_foreign_key "group_subscriptions", "users"
  add_foreign_key "settles", "users", column: "receiver"
  add_foreign_key "settles", "users", column: "sender"
end
