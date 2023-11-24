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

ActiveRecord::Schema.define(version: 2020_10_23_112140) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "github_url"
    t.integer "github_installation_id"
    t.index ["uid"], name: "index_projects_on_uid"
  end

  create_table "test_cases", force: :cascade do |t|
    t.string "classname"
    t.string "name"
    t.string "file"
    t.decimal "time"
    t.boolean "skipped"
    t.text "failure"
    t.bigint "test_run_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "hash_code", null: false
    t.index ["hash_code"], name: "index_test_cases_on_hash_code"
    t.index ["test_run_id"], name: "index_test_cases_on_test_run_id"
  end

  create_table "test_runs", force: :cascade do |t|
    t.string "name"
    t.integer "tests"
    t.integer "skipped"
    t.integer "failures"
    t.integer "errored"
    t.decimal "time"
    t.datetime "timestamp"
    t.string "hostname"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "project_id"
    t.string "branch"
    t.string "commit"
    t.index ["project_id"], name: "index_test_runs_on_project_id"
  end

  add_foreign_key "test_cases", "test_runs"
  add_foreign_key "test_runs", "projects"
end
