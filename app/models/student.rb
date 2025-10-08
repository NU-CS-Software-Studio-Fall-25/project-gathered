class Student < ApplicationRecord
  # Associations
  has_many :student_courses, primary_key: :student_id, foreign_key: :student_id, dependent: :destroy
  has_many :courses, through: :student_courses
  has_many :group_memberships, primary_key: :student_id, foreign_key: :student_id, dependent: :destroy
  has_many :study_groups, through: :group_memberships, source: :group
  has_many :created_study_groups, class_name: "StudyGroup", foreign_key: :creator_id, primary_key: :student_id

  # Validations
  validates :name, length: { maximum: 100 }

  # Methods
  def enrolled_in?(course)
    courses.include?(course)
  end

  def member_of?(study_group)
    study_groups.include?(study_group)
  end
end
