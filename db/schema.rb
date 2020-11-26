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

ActiveRecord::Schema.define(version: 20201122095219) do

  create_table "attendance_logs", force: :cascade do |t|
    t.date "worked_on_log"
    t.datetime "started_at_log_before_change"
    t.datetime "finished_at_log_before_change"
    t.datetime "started_at_log_after_change"
    t.datetime "finished_at_log_after_change"
    t.string "approval_superior_name"
    t.datetime "approval_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_attendance_logs_on_user_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "month_approval_status"
    t.datetime "started_at_after_approval"
    t.datetime "finished_at_after_approval"
    t.integer "change_approval_superior_id"
    t.integer "change_approval_status"
    t.boolean "change_next_day_check"
    t.datetime "overwork_finished_at"
    t.integer "overwork_approval_superior_id"
    t.string "overwork_content"
    t.integer "overwork_approval_status"
    t.boolean "overwork_next_day_check"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.string "name"
    t.string "number"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "month_approvals", force: :cascade do |t|
    t.integer "applicant_user_id"
    t.integer "approval_superior_id"
    t.integer "approval_status"
    t.date "approval_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_month_approvals_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.datetime "basic_time", default: "2020-11-25 23:00:00"
    t.datetime "work_time", default: "2020-11-25 22:30:00"
    t.integer "employee_number"
    t.string "uid"
    t.datetime "designated_work_start_time", default: "2020-11-26 00:00:00"
    t.datetime "designated_work_end_time", default: "2020-11-26 09:00:00"
    t.boolean "superior"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
