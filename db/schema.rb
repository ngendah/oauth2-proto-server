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

ActiveRecord::Schema.define(version: 2018_04_26_082453) do

  create_table "access_tokens", force: :cascade do |t|
    t.string "token", null: false
    t.integer "client_id"
    t.integer "user_id"
    t.datetime "expires", null: false
    t.integer "scopes"
    t.boolean "refresh", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_access_tokens_on_client_id"
    t.index ["token"], name: "index_access_tokens_on_token"
    t.index ["user_id"], name: "index_access_tokens_on_user_id"
  end

  create_table "authorization_codes", force: :cascade do |t|
    t.string "code", null: false
    t.integer "client_id"
    t.integer "user_id"
    t.string "redirect_url"
    t.datetime "expires", null: false
    t.integer "scopes"
    t.integer "access_token_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token_id"], name: "index_authorization_codes_on_access_token_id"
    t.index ["client_id"], name: "index_authorization_codes_on_client_id"
    t.index ["code"], name: "index_authorization_codes_on_code"
    t.index ["user_id"], name: "index_authorization_codes_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "uid", null: false
    t.string "secret", null: false
    t.string "redirect_uri"
    t.string "grant_type"
    t.integer "scope"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_clients_on_uid"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "jwts", force: :cascade do |t|
    t.integer "client_id"
    t.string "subject"
    t.string "public_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_jwts_on_client_id"
  end

  create_table "scopes", force: :cascade do |t|
    t.string "scope", null: false
    t.boolean "is_default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scope"], name: "index_scopes_on_scope"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid", null: false
    t.string "password_digest", null: false
    t.integer "scope"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_users_on_uid"
  end

end
