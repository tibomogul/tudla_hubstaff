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

ActiveRecord::Schema[8.1].define(version: 2025_12_31_043338) do
  create_table "tudla_hubstaff_projects", force: :cascade do |t|
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "last_updated_at"
    t.json "metadata", default: {}, null: false
    t.string "name", null: false
    t.bigint "project_id"
    t.string "project_type", null: false
    t.string "status"
    t.bigint "tudla_project_id"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_tudla_hubstaff_projects_on_client_id"
    t.index ["project_id"], name: "index_tudla_hubstaff_projects_on_project_id"
    t.index ["tudla_project_id"], name: "index_tudla_hubstaff_projects_on_tudla_project_id"
  end

  create_table "tudla_hubstaff_tasks", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "details"
    t.datetime "due_at"
    t.integer "integration_id"
    t.datetime "last_updated_at"
    t.integer "lock_version"
    t.json "metadata", default: {}, null: false
    t.integer "project_id", null: false
    t.string "project_type", null: false
    t.string "remote_alternate_id"
    t.string "remote_id"
    t.string "status"
    t.string "summary", null: false
    t.bigint "task_id"
    t.bigint "tudla_task_id"
    t.datetime "updated_at", null: false
    t.index ["remote_id"], name: "index_tudla_hubstaff_tasks_on_remote_id"
    t.index ["task_id"], name: "index_tudla_hubstaff_tasks_on_task_id"
    t.index ["tudla_task_id"], name: "index_tudla_hubstaff_tasks_on_tudla_task_id"
  end

  create_table "tudla_hubstaff_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.string "ip_address"
    t.string "last_name", null: false
    t.datetime "last_updated_at"
    t.string "name", null: false
    t.string "status", default: "active", null: false
    t.string "time_zone", default: "UTC", null: false
    t.bigint "tudla_user_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["email"], name: "index_tudla_hubstaff_users_on_email", unique: true
    t.index ["tudla_user_id"], name: "index_tudla_hubstaff_users_on_tudla_user_id"
    t.index ["user_id"], name: "index_tudla_hubstaff_users_on_user_id"
  end
end
