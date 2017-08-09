# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170808232647) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "account_number"
    t.string "account_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "holdings", force: :cascade do |t|
    t.bigint "account_id"
    t.string "name"
    t.string "symbol"
    t.integer "shares"
    t.integer "current_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_holdings_on_account_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "age"
    t.string "goal"
    t.string "risk_tolerance"
    t.string "current_portfolio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "holding_id"
    t.boolean "buy", default: false
    t.boolean "sell", default: false
    t.integer "execution_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["holding_id"], name: "index_transactions_on_holding_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
