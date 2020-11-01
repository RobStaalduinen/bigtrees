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

ActiveRecord::Schema.define(version: 20201019164050) do

  create_table "addresses", force: :cascade do |t|
    t.string   "street",      limit: 255
    t.string   "city",        limit: 255
    t.string   "postal_code", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

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
    t.string  "name",            limit: 255,                 null: false
    t.string  "certification",   limit: 255,                 null: false
    t.string  "phone_number",    limit: 255
    t.string  "email",           limit: 255
    t.string  "password",        limit: 255
    t.boolean "is_admin",                    default: false
    t.string  "session_token",   limit: 255
    t.string  "password_digest", limit: 255
    t.boolean "admin",                       default: false
    t.boolean "hidden",                      default: false
    t.boolean "active",                      default: true
    t.float   "hourly_rate",     limit: 24
  end

  create_table "costs", force: :cascade do |t|
    t.integer "estimate_id", limit: 4
    t.decimal "amount",                  precision: 10
    t.string  "description", limit: 255
    t.boolean "discount",                               default: false
  end

  create_table "customers", force: :cascade do |t|
    t.string  "name",              limit: 255
    t.string  "email",             limit: 255
    t.string  "phone",             limit: 255
    t.string  "preferred_contact", limit: 255
    t.integer "address_id",        limit: 4
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "documents", force: :cascade do |t|
    t.integer  "arborist_id",       limit: 4
    t.string   "name",              limit: 255
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size",    limit: 4
    t.datetime "file_updated_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "documents", ["arborist_id"], name: "index_documents_on_arborist_id", using: :btree

  create_table "equipment_requests", force: :cascade do |t|
    t.integer  "arborist_id",        limit: 4
    t.integer  "vehicle_id",         limit: 4
    t.date     "submitted_at"
    t.string   "category",           limit: 255
    t.text     "description",        limit: 65535
    t.string   "state",              limit: 255,   default: "submitted"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  create_table "estimates", force: :cascade do |t|
    t.integer  "tree_quantity",           limit: 4,                  default: 1
    t.string   "street",                  limit: 255
    t.string   "city",                    limit: 255
    t.boolean  "stump_removal",                                      default: false
    t.boolean  "vehicle_access",                                     default: false
    t.boolean  "breakables",                                         default: false
    t.boolean  "wood_removal",                                       default: false
    t.integer  "status",                  limit: 4,                  default: 0,     null: false
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.boolean  "submission_completed",                               default: false
    t.date     "quote_sent_date"
    t.date     "quote_accepted_date"
    t.date     "work_date"
    t.decimal  "extra_cost",                          precision: 10
    t.string   "extra_cost_notes",        limit: 255
    t.integer  "arborist_id",             limit: 4
    t.date     "cancelled_at"
    t.boolean  "stumping_only",                                      default: false
    t.string   "access_width",            limit: 255
    t.boolean  "is_unknown",                                         default: false
    t.integer  "customer_id",             limit: 4
    t.date     "picture_request_sent_at"
    t.datetime "followup_sent_at"
  end

  create_table "expirations", force: :cascade do |t|
    t.integer  "vehicle_id", limit: 4
    t.string   "name",       limit: 255
    t.date     "date"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "extra_costs", force: :cascade do |t|
    t.integer "estimate_id", limit: 4
    t.decimal "amount",                  precision: 10
    t.string  "description", limit: 255
  end

  add_index "extra_costs", ["estimate_id"], name: "index_extra_costs_on_estimate_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer "estimate_id",    limit: 4
    t.string  "number",         limit: 255
    t.string  "payment_method", limit: 255
    t.boolean "paid",                       default: false
    t.boolean "discount",                   default: false
    t.date    "sent_at"
    t.date    "paid_at"
  end

  add_index "invoices", ["estimate_id"], name: "index_invoices_on_estimate_id", using: :btree
  add_index "invoices", ["number"], name: "index_invoices_on_number", using: :btree

  create_table "payouts", force: :cascade do |t|
    t.date     "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "receipts", force: :cascade do |t|
    t.integer  "arborist_id",        limit: 4
    t.date     "date"
    t.string   "category",           limit: 255
    t.string   "job",                limit: 255
    t.string   "payment_method",     limit: 255
    t.string   "description",        limit: 255
    t.decimal  "cost",                           precision: 10
    t.string   "photo_file_name",    limit: 255
    t.string   "photo_content_type", limit: 255
    t.integer  "photo_file_size",    limit: 4
    t.datetime "photo_updated_at"
    t.integer  "vehicle_id",         limit: 4
    t.boolean  "approved",                                      default: false
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

  create_table "sites", force: :cascade do |t|
    t.integer "estimate_id",      limit: 4
    t.string  "street",           limit: 255
    t.string  "city",             limit: 255
    t.boolean "wood_removal",                 default: true
    t.boolean "vehicle_access",               default: false
    t.boolean "breakables",                   default: false
    t.string  "access_width",     limit: 255
    t.boolean "cleanup",                      default: false
    t.integer "address_id",       limit: 4
    t.boolean "low_access_width",             default: false
  end

  add_index "sites", ["estimate_id"], name: "index_sites_on_estimate_id", using: :btree

  create_table "tree_images", force: :cascade do |t|
    t.string   "asset_file_name",    limit: 255
    t.string   "asset_content_type", limit: 255
    t.integer  "asset_file_size",    limit: 4
    t.datetime "asset_updated_at"
    t.integer  "tree_id",            limit: 4
    t.string   "image_url",          limit: 255
  end

  create_table "trees", force: :cascade do |t|
    t.integer "estimate_id",   limit: 4
    t.integer "work_type",     limit: 4,                  default: 0
    t.integer "sequence",      limit: 4,                  default: 0
    t.decimal "cost",                      precision: 10
    t.string  "notes",         limit: 255
    t.string  "description",   limit: 255
    t.boolean "stump_removal"
    t.boolean "in_backyard",                              default: false
  end

  add_index "trees", ["estimate_id"], name: "index_trees_on_estimate_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string "username",      limit: 50,  null: false
    t.string "session_token", limit: 100, null: false
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "name", limit: 255
  end

  add_index "vehicles", ["name"], name: "index_vehicles_on_name", using: :btree

  create_table "work_actions", force: :cascade do |t|
    t.integer "estimate_id",  limit: 4,     null: false
    t.string  "work_type",    limit: 255,   null: false
    t.integer "tree_index",   limit: 4,     null: false
    t.integer "tree_stories", limit: 4
    t.text    "info",         limit: 65535
    t.float   "cost",         limit: 24
    t.string  "status",       limit: 255,   null: false
  end

  create_table "work_records", force: :cascade do |t|
    t.integer "arborist_id",  limit: 4
    t.date    "date"
    t.float   "hours",        limit: 24
    t.time    "start_at"
    t.time    "end_at"
    t.float   "unpaid_hours", limit: 24
    t.float   "hourly_rate",  limit: 24
    t.integer "payout_id",    limit: 4
  end

  add_index "work_records", ["arborist_id"], name: "index_work_records_on_arborist_id", using: :btree

end
