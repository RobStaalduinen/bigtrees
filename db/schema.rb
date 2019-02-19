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

ActiveRecord::Schema.define(version: 20190128200854) do

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

  create_table "arborists", force: :cascade do |t|
    t.string  "name",                          null: false
    t.string  "certification",                 null: false
    t.string  "phone_number"
    t.string  "email"
    t.string  "password"
    t.boolean "is_admin",      default: false
    t.string  "session_token"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "estimates", force: :cascade do |t|
    t.integer  "tree_quantity",         default: 1
    t.string   "person_name"
    t.string   "street"
    t.string   "city"
    t.string   "phone"
    t.string   "email"
    t.boolean  "stump_removal",         default: false
    t.boolean  "vehicle_access",        default: false
    t.boolean  "breakables",            default: false
    t.boolean  "wood_removal",          default: false
    t.integer  "status",                default: 0,     null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "submission_completed",  default: false
    t.date     "quote_sent_date"
    t.date     "quote_accepted_date"
    t.date     "work_date"
    t.decimal  "extra_cost"
    t.string   "extra_cost_notes"
    t.integer  "arborist_id"
    t.integer  "invoice_number"
    t.boolean  "discount_applied",      default: false
    t.string   "payment_method"
    t.date     "final_invoice_sent_at"
    t.date     "cancelled_at"
  end

  create_table "receipts", force: :cascade do |t|
    t.integer  "arborist_id"
    t.date     "date"
    t.string   "category"
    t.string   "job"
    t.string   "payment_method"
    t.string   "description"
    t.decimal  "cost"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer  "vehicle_id"
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
    t.integer  "estimate_id",        limit: 4, null: false
    t.integer  "tree_number",        limit: 4, null: false
    t.string   "asset_file_name"
    t.string   "asset_content_type"
    t.integer  "asset_file_size"
    t.datetime "asset_updated_at"
    t.integer  "tree_id"
  end

  create_table "trees", force: :cascade do |t|
    t.integer "estimate_id"
    t.integer "work_type",   default: 0
    t.integer "sequence",    default: 0
    t.decimal "cost"
    t.string  "notes"
  end

  add_index "trees", ["estimate_id"], name: "index_trees_on_estimate_id"

  create_table "users", force: :cascade do |t|
    t.string "username",      limit: 50,  null: false
    t.string "password",      limit: 50,  null: false
    t.string "session_token", limit: 100, null: false
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "name"
  end

  add_index "vehicles", ["name"], name: "index_vehicles_on_name"

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
