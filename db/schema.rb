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

ActiveRecord::Schema[7.0].define(version: 2022_09_14_140417) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "jtis", primary_key: "jti", id: :string, force: :cascade do |t|
    t.datetime "exp", null: false, comment: "Expiration of JWT"
    t.bigint "user_id", null: false
    t.string "agent", null: false, comment: "HTTP agent of the user when issued"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_jtis_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.integer "amount"
    t.bigint "price_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "user_id", "product_id"], name: "index_order_items_on_order_id_and_user_id_and_product_id", unique: true
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["price_id"], name: "index_order_items_on_price_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["user_id"], name: "index_order_items_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "prices", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.datetime "from", null: false
    t.decimal "value", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "from"], name: "index_prices_on_product_id_and_from", unique: true
    t.index ["product_id"], name: "index_prices_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_products_on_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.boolean "admin", default: false
    t.string "password_digest", null: false
    t.string "password_reset_token", comment: "When locked or password forgot"
    t.integer "password_attempts", default: 0, comment: "Count of failed attempts signing in with password"
    t.datetime "locked_at"
    t.integer "max_tokens", default: 5, comment: "Max allowed simultaneous tokens that can be issued"
    t.integer "token_duration", default: 900, comment: "Default duration of token in seconds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "prices"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_items", "users"
  add_foreign_key "orders", "users"
  add_foreign_key "prices", "products"
end
