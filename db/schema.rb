# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 0) do

  create_table "appointments", force: :cascade do |t|
    t.integer "estimate_id",    limit: 4
    t.string  "date_submitted", limit: 255, null: false
    t.string  "name",           limit: 255, null: false
    t.string  "address",        limit: 255, null: false
    t.string  "city",           limit: 100
    t.string  "tree_quantity",  limit: 5
    t.string  "contact_method", limit: 255, null: false
    t.string  "contact_type",   limit: 20
    t.string  "status",         limit: 50,  null: false
  end

  create_table "estimates", force: :cascade do |t|
    t.string  "estimate_number", limit: 15
    t.string  "name",            limit: 255,   null: false
    t.string  "date_submitted",  limit: 40,    null: false
    t.integer "tree_quantity",   limit: 4,     null: false
    t.text    "address",         limit: 65535, null: false
    t.string  "city",            limit: 100
    t.string  "contact_type",    limit: 255
    t.string  "contact_method",  limit: 255
    t.string  "status",          limit: 255,   null: false
    t.string  "response",        limit: 20
    t.string  "last_change",     limit: 12
    t.string  "stump_removal",   limit: 5
    t.string  "vehicle_access",  limit: 5
    t.string  "breakables",      limit: 5
    t.string  "wood_removal",    limit: 5
  end

  create_table "site_config", force: :cascade do |t|
    t.string "attribute_name",  limit: 255, null: false
    t.string "attribute_value", limit: 255, null: false
  end

  create_table "site_stats", force: :cascade do |t|
    t.integer "estimates_started",    limit: 4,  default: 0, null: false
    t.integer "appointments_started", limit: 4,  default: 0, null: false
    t.string  "month",                limit: 20,             null: false
    t.string  "year",                 limit: 10
  end

  create_table "tree_images", force: :cascade do |t|
    t.integer "estimate_id", limit: 4,   null: false
    t.string  "filename",    limit: 255, null: false
    t.integer "tree_number", limit: 4,   null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username",      limit: 50,  null: false
    t.string "password",      limit: 50,  null: false
    t.string "session_token", limit: 100, null: false
  end

  create_table "work_actions", force: :cascade do |t|
    t.integer "estimate_id",  limit: 4,     null: false
    t.string  "work_type",    limit: 255,   null: false
    t.integer "tree_index",   limit: 4,     null: false
    t.integer "tree_stories", limit: 4
    t.text    "info",         limit: 65535
    t.float   "cost",         limit: 24
    t.string  "status",       limit: 255,   null: false
  end

end
