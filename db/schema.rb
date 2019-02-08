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

ActiveRecord::Schema.define(version: 2019_01_24_183107) do

  create_table "moodle_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci", force: :cascade do |t|
    t.string "host"
    t.string "token"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "teacher_emails"
    t.text "signin_email_text"
    t.index ["user_id"], name: "index_moodle_details_on_user_id"
  end

  create_table "moodle_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci", force: :cascade do |t|
    t.string "profile_image_url"
    t.string "full_name"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.integer "moodle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "report_run_id"
    t.index ["report_run_id"], name: "index_moodle_users_on_report_run_id"
  end

  create_table "report_runs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "run_params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "end_date"
    t.index ["user_id"], name: "index_report_runs_on_user_id"
  end

  create_table "reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "report_type"
    t.text "contents", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "report_run_id"
    t.index ["report_run_id"], name: "index_reports_on_report_run_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "submissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci", force: :cascade do |t|
    t.datetime "date_submitted"
    t.datetime "date_graded"
    t.integer "grade_raw"
    t.string "item_module"
    t.integer "item_instance_id"
    t.bigint "moodle_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "course_id"
    t.string "status"
    t.index ["moodle_user_id"], name: "index_submissions_on_moodle_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "moodle_details", "users"
  add_foreign_key "moodle_users", "report_runs"
  add_foreign_key "report_runs", "users"
  add_foreign_key "reports", "report_runs"
  add_foreign_key "reports", "users"
  add_foreign_key "submissions", "moodle_users"
end
