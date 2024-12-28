# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_12_28_094517) do

  create_table "addresses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "street"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "addressable_id"
    t.string "addressable_type"
    t.string "postal_code"
    t.index ["addressable_id"], name: "index_addresses_on_addressable_id"
    t.index ["addressable_type"], name: "index_addresses_on_addressable_type"
    t.index ["city"], name: "index_addresses_on_city"
    t.index ["street"], name: "index_addresses_on_street"
  end

  create_table "appointments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "estimate_id"
    t.string "date_submitted", null: false
    t.string "name", null: false
    t.string "address", null: false
    t.string "city", limit: 100
    t.string "tree_quantity", limit: 5
    t.string "contact_method", null: false
    t.string "contact_type", limit: 20
    t.string "status", limit: 50, null: false
  end

  create_table "arborists", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", null: false
    t.string "certification"
    t.string "phone_number"
    t.string "email"
    t.string "password"
    t.boolean "is_admin", default: false
    t.string "session_token"
    t.string "password_digest"
    t.boolean "admin", default: false
    t.boolean "hidden", default: false
    t.boolean "active", default: true
    t.float "hourly_rate"
    t.boolean "can_manage_estimates", default: false
    t.integer "organization_id"
    t.string "role", default: "arborist"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
  end

  create_table "costs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "estimate_id"
    t.float "amount"
    t.string "description"
    t.boolean "discount", default: false
  end

  create_table "customer_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "estimate_id"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customer_details_on_email"
    t.index ["estimate_id"], name: "index_customer_details_on_estimate_id"
    t.index ["name"], name: "index_customer_details_on_name"
    t.index ["phone"], name: "index_customer_details_on_phone"
  end

  create_table "customers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "preferred_contact"
    t.integer "address_id"
    t.string "short_name"
    t.index ["email"], name: "index_customers_on_email"
    t.index ["name"], name: "index_customers_on_name"
    t.index ["phone"], name: "index_customers_on_phone"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "documents", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "arborist_id"
    t.string "name"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "expires_at"
    t.string "url"
    t.index ["arborist_id"], name: "index_documents_on_arborist_id"
  end

  create_table "email_templates", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "key"
    t.string "subject"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_email_templates_on_key"
    t.index ["organization_id"], name: "index_email_templates_on_organization_id"
  end

  create_table "equipment_assignments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "estimate_id"
    t.integer "vehicle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "equipment_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "arborist_id"
    t.integer "vehicle_id"
    t.date "submitted_at"
    t.string "category"
    t.text "description"
    t.string "state", default: "submitted"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.integer "resolver_id"
    t.string "resolution_notes"
    t.integer "mechanic_id"
    t.integer "organization_id"
    t.index ["resolver_id"], name: "index_equipment_requests_on_resolver_id"
  end

  create_table "estimates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "tree_quantity", default: 1
    t.string "street"
    t.string "city"
    t.boolean "stump_removal", default: false
    t.boolean "vehicle_access", default: false
    t.boolean "breakables", default: false
    t.boolean "wood_removal", default: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "submission_completed", default: false
    t.date "quote_sent_date"
    t.date "quote_accepted_date"
    t.date "work_start_date"
    t.decimal "extra_cost", precision: 10
    t.string "extra_cost_notes"
    t.integer "arborist_id"
    t.date "cancelled_at"
    t.boolean "stumping_only", default: false
    t.string "access_width"
    t.boolean "is_unknown", default: false
    t.integer "customer_id"
    t.date "picture_request_sent_at"
    t.datetime "followup_sent_at"
    t.date "work_end_date"
    t.date "work_completion_date"
    t.boolean "skip_schedule"
    t.integer "organization_id"
    t.boolean "pending_permit", default: false
    t.boolean "site_visit_tag", default: false
    t.index ["arborist_id"], name: "index_estimates_on_arborist_id"
    t.index ["cancelled_at"], name: "index_estimates_on_cancelled_at"
    t.index ["created_at"], name: "index_estimates_on_created_at"
    t.index ["customer_id"], name: "index_estimates_on_customer_id"
    t.index ["followup_sent_at"], name: "index_estimates_on_followup_sent_at"
    t.index ["is_unknown"], name: "index_estimates_on_is_unknown"
    t.index ["picture_request_sent_at"], name: "index_estimates_on_picture_request_sent_at"
    t.index ["status"], name: "index_estimates_on_status"
    t.index ["submission_completed"], name: "index_estimates_on_submission_completed"
  end

  create_table "expirations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "vehicle_id"
    t.string "name"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "extra_costs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "estimate_id"
    t.decimal "amount", precision: 10
    t.string "description"
    t.index ["estimate_id"], name: "index_extra_costs_on_estimate_id"
  end

  create_table "images", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "imageable_id"
    t.string "imageable_type"
    t.string "image_url"
    t.string "edited_image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "estimate_id"
    t.string "number"
    t.string "payment_method"
    t.boolean "paid", default: false
    t.boolean "discount", default: false
    t.date "sent_at"
    t.date "paid_at"
    t.index ["estimate_id"], name: "index_invoices_on_estimate_id"
    t.index ["number"], name: "index_invoices_on_number"
  end

  create_table "notes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "estimate_id"
    t.integer "arborist_id"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arborist_id"], name: "index_notes_on_arborist_id"
    t.index ["estimate_id"], name: "index_notes_on_estimate_id"
  end

  create_table "organization_memberships", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "arborist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "hourly_rate", default: 0.0
    t.index ["arborist_id"], name: "index_organization_memberships_on_arborist_id"
    t.index ["organization_id"], name: "index_organization_memberships_on_organization_id"
  end

  create_table "organizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.string "website"
    t.string "email"
    t.string "email_author"
    t.string "outgoing_quote_email"
    t.string "quote_bcc"
    t.string "email_signature"
    t.string "insurance_provider"
    t.string "insurance_policy_number"
    t.string "insurance_description"
    t.string "hst_number"
    t.integer "address_id"
    t.string "short_name"
    t.string "logo_url"
    t.string "primary_colour"
    t.string "secondary_colour"
    t.string "condensed_logo_url"
  end

  create_table "payouts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quick_costs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "label"
    t.string "content"
    t.decimal "default_cost", precision: 8, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_quick_costs_on_organization_id"
  end

  create_table "receipts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "arborist_id"
    t.date "date"
    t.string "category"
    t.string "job"
    t.string "payment_method"
    t.string "description"
    t.decimal "cost", precision: 10
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer "vehicle_id"
    t.boolean "approved", default: false
    t.string "image_url"
    t.string "state", default: "pending"
    t.string "rejection_reason"
    t.integer "organization_id"
    t.index ["state"], name: "index_receipts_on_state"
  end

  create_table "site_config", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "attribute_name", null: false
    t.string "attribute_value", null: false
  end

  create_table "site_stats", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "estimates_started", default: 0, null: false
    t.integer "appointments_started", default: 0, null: false
    t.string "month", limit: 20, null: false
    t.string "year", limit: 10
  end

  create_table "sites", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "estimate_id"
    t.string "street"
    t.string "city"
    t.boolean "wood_removal", default: true
    t.boolean "vehicle_access", default: false
    t.boolean "breakables", default: false
    t.string "access_width"
    t.boolean "cleanup", default: false
    t.integer "address_id"
    t.boolean "low_access_width", default: false
    t.boolean "survey_filled_out", default: false
    t.boolean "visit_consent", default: false
    t.text "visit_times"
    t.index ["city"], name: "index_sites_on_city"
    t.index ["estimate_id"], name: "index_sites_on_estimate_id"
    t.index ["street"], name: "index_sites_on_street"
  end

  create_table "tree_images", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "asset_file_name"
    t.string "asset_content_type"
    t.integer "asset_file_size"
    t.datetime "asset_updated_at"
    t.integer "tree_id"
    t.string "image_url"
    t.string "image_small_url"
    t.string "edited_image_url"
    t.integer "estimate_id"
  end

  create_table "trees", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "estimate_id"
    t.integer "work_type", default: 0
    t.integer "sequence", default: 0
    t.decimal "cost", precision: 10
    t.string "notes"
    t.string "description"
    t.boolean "stump_removal"
    t.boolean "in_backyard", default: false
    t.string "job_type"
    t.index ["estimate_id"], name: "index_trees_on_estimate_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "username", limit: 50, null: false
    t.string "session_token", limit: 100, null: false
  end

  create_table "vehicles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "organization_id"
    t.index ["name"], name: "index_vehicles_on_name"
  end

  create_table "work_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "estimate_id", null: false
    t.string "work_type", null: false
    t.integer "tree_index", null: false
    t.integer "tree_stories"
    t.text "info"
    t.float "cost"
    t.string "status", null: false
  end

  create_table "work_records", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "arborist_id"
    t.date "date"
    t.float "hours"
    t.time "start_at"
    t.time "end_at"
    t.float "unpaid_hours"
    t.float "hourly_rate"
    t.integer "payout_id"
    t.integer "organization_id"
    t.index ["arborist_id"], name: "index_work_records_on_arborist_id"
  end

end
