class Student < ApplicationRecord
  # Authentication
  has_secure_password

  # Associations
  has_many :student_courses, primary_key: :student_id, foreign_key: :student_id, dependent: :destroy
  has_many :courses, through: :student_courses
  has_many :group_memberships, primary_key: :student_id, foreign_key: :student_id, dependent: :destroy
  has_many :study_groups, through: :group_memberships, source: :group
  has_many :created_study_groups, class_name: "StudyGroup", foreign_key: :creator_id, primary_key: :student_id

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # Methods
  def enrolled_in?(course)
    courses.include?(course)
  end

  def member_of?(study_group)
    study_groups.include?(study_group)
  end

  def self.authenticate(email, password)
    find_by(email: email)&.authenticate(password)
  end
end
