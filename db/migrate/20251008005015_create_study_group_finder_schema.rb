class CreateStudyGroupFinderSchema < ActiveRecord::Migration[7.1]
  def change
    # student table
    create_table :students, primary_key: :student_id do |t|
      t.string :name, limit: 100
      t.timestamp :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    # course table
    create_table :courses, primary_key: :course_id do |t|
      t.string :course_name, limit: 100, null: false
      t.text   :description
      t.string :professor, limit: 100
      t.timestamp :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    # study_group table
    create_table :study_groups, primary_key: :group_id do |t|
      t.integer :course_id,  null: false
      t.integer :creator_id, null: false
      t.string  :topic,      limit: 150, null: false
      t.text    :description
      t.string  :location,   limit: 150
      t.timestamp :start_time, null: false
      t.timestamp :end_time,   null: false
      t.timestamp :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
    add_foreign_key :study_groups, :courses, column: :course_id,  primary_key: :course_id
    add_foreign_key :study_groups, :students, column: :creator_id, primary_key: :student_id

    # student_courses (join table)
    create_table :student_courses, id: false do |t|
      t.integer :student_id, null: false
      t.integer :course_id,  null: false
      t.timestamp :joined_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
    add_index :student_courses, [:student_id, :course_id], unique: true, name: "idx_student_courses_unique"
    add_foreign_key :student_courses, :students, column: :student_id, primary_key: :student_id, on_delete: :cascade
    add_foreign_key :student_courses, :courses, column: :course_id,  primary_key: :course_id,  on_delete: :cascade

    # group_memberships (join table)
    create_table :group_memberships, id: false do |t|
      t.integer :student_id, null: false
      t.integer :group_id,   null: false
      t.timestamp :joined_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
    add_index :group_memberships, [:group_id, :student_id], unique: true, name: "idx_group_memberships_unique"
    add_foreign_key :group_memberships, :students, column: :student_id, primary_key: :student_id, on_delete: :cascade
    add_foreign_key :group_memberships, :study_groups, column: :group_id,   primary_key: :group_id,   on_delete: :cascade
  end
end
