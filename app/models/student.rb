class Student < ApplicationRecord
  # Authentication
  has_secure_password

  # Callbacks
  before_create :set_random_avatar_color

  # Associations
  has_many :student_courses, primary_key: :student_id, foreign_key: :student_id, dependent: :destroy
  has_many :courses, through: :student_courses
  has_many :group_memberships, primary_key: :student_id, foreign_key: :student_id, dependent: :destroy
  has_many :study_groups, through: :group_memberships, source: :group
  has_many :created_study_groups, class_name: "StudyGroup", foreign_key: :creator_id, primary_key: :student_id

  # Active Storage
  has_one_attached :avatar

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :uid, uniqueness: { scope: :provider }, allow_nil: true
  validates :provider, presence: true, if: -> { uid.present? }
  validate :acceptable_avatar

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

  def self.from_omniauth(auth)
    student = find_or_initialize_by(email: auth.info.email)
    student.name = auth.info.name.presence || student.name || auth.info.first_name || "Student"
    student.provider = auth.provider
    student.uid = auth.uid
    student.password = SecureRandom.hex(32) if student.password_digest.blank?
    student.avatar_color ||= Student.random_avatar_color
    student.save!
    student
  end

  def self.random_avatar_color
    # Google-style avatar colors: vibrant and distinct
    colors = [
      '#F44336', # Red
      '#E91E63', # Pink
      '#9C27B0', # Purple
      '#673AB7', # Deep Purple
      '#3F51B5', # Indigo
      '#2196F3', # Blue
      '#03A9F4', # Light Blue
      '#00BCD4', # Cyan
      '#009688', # Teal
      '#4CAF50', # Green
      '#8BC34A', # Light Green
      '#FF9800', # Orange
      '#FF5722', # Deep Orange
      '#795548', # Brown
      '#607D8B'  # Blue Grey
    ]
    colors.sample
  end

  private

  def set_random_avatar_color
    self.avatar_color ||= Student.random_avatar_color
  end

  def acceptable_avatar
    return unless avatar.attached?

    # Validate content type (only JPEG and PNG allowed)
    acceptable_types = [ "image/jpeg", "image/png" ]
    unless acceptable_types.include?(avatar.content_type)
      errors.add(:avatar, "must be a JPEG or PNG image")
    end

    # Validate file size (max 5MB)
    if avatar.byte_size > 5.megabytes
      errors.add(:avatar, "is too large (maximum is 5MB)")
    end
  end
end
