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

ActiveRecord::Schema[8.0].define(version: 2025_12_07_022019) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "courses", primary_key: "course_id", force: :cascade do |t|
    t.string "course_name", limit: 100, null: false
    t.text "description"
    t.string "professor", limit: 100
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "group_memberships", id: false, force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "group_id", null: false
    t.datetime "joined_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["group_id", "student_id"], name: "idx_group_memberships_unique", unique: true
  end

  create_table "student_courses", id: false, force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "course_id", null: false
    t.datetime "joined_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["student_id", "course_id"], name: "idx_student_courses_unique", unique: true
  end

  create_table "students", primary_key: "student_id", force: :cascade do |t|
    t.string "name", limit: 100
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "email", null: false
    t.string "password_digest"
    t.string "avatar_color"
    t.string "provider"
    t.string "uid"
    t.boolean "high_contrast", default: false, null: false
    t.index ["email"], name: "index_students_on_email", unique: true
    t.index ["provider", "uid"], name: "index_students_on_provider_and_uid", unique: true, where: "(provider IS NOT NULL)"
  end

  create_table "study_groups", primary_key: "group_id", force: :cascade do |t|
    t.integer "course_id", null: false
    t.integer "creator_id", null: false
    t.string "topic", limit: 150, null: false
    t.text "description"
    t.string "location", limit: 150
    t.datetime "start_time", precision: nil, null: false
    t.datetime "end_time", precision: nil, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "group_memberships", "students", primary_key: "student_id", on_delete: :cascade
  add_foreign_key "group_memberships", "study_groups", column: "group_id", primary_key: "group_id", on_delete: :cascade
  add_foreign_key "student_courses", "courses", primary_key: "course_id", on_delete: :cascade
  add_foreign_key "student_courses", "students", primary_key: "student_id", on_delete: :cascade
  add_foreign_key "study_groups", "courses", primary_key: "course_id"
  add_foreign_key "study_groups", "students", column: "creator_id", primary_key: "student_id"
end
