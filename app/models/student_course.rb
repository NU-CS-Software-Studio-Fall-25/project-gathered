class StudentCourse < ApplicationRecord
  # Associations
  belongs_to :student, primary_key: :student_id, foreign_key: :student_id
  belongs_to :course, primary_key: :course_id, foreign_key: :course_id

  # Validations
  validates :student_id, uniqueness: { scope: :course_id, message: "already enrolled in this course" }
end
