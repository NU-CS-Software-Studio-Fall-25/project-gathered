class Course < ApplicationRecord
  # Associations
  has_many :study_groups, primary_key: :course_id, foreign_key: :course_id, dependent: :destroy
  has_many :student_courses, primary_key: :course_id, foreign_key: :course_id, dependent: :destroy
  has_many :students, through: :student_courses

  # Validations
  validates :course_name, presence: true, length: { maximum: 100 }
  validates :professor, length: { maximum: 100 }


  # Methods
  def enrolled_student_count
    students.count
  end

  def study_group_count
    study_groups.count
  end

  private


end
