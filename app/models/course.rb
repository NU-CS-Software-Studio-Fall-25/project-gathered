class Course < ApplicationRecord
  # Associations
  has_many :study_groups, primary_key: :course_id, foreign_key: :course_id, dependent: :destroy
  has_many :student_courses, primary_key: :course_id, foreign_key: :course_id, dependent: :destroy
  has_many :students, through: :student_courses

  # Validations
  validates :course_name, presence: true, length: { maximum: 100 }
  validates :professor, length: { maximum: 100 }
  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date

  # Methods
  def enrolled_student_count
    students.count
  end

  def study_group_count
    study_groups.count
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    
    if end_date <= start_date
      errors.add(:end_date, "must be after start_date")
    end
  end
end
