class StudyGroup < ApplicationRecord
  # Associations
  belongs_to :course, primary_key: :course_id, foreign_key: :course_id
  belongs_to :creator, class_name: "Student", primary_key: :student_id, foreign_key: :creator_id
  has_many :group_memberships, primary_key: :group_id, foreign_key: :group_id, dependent: :destroy
  has_many :members, through: :group_memberships, source: :student

  after_create_commit :add_creator_membership

  # Validations
  validates :topic, presence: { message: "Topic is required - please enter a topic" },
                    length: { minimum: 3, maximum: 100, message: "must be between 3 and 100 characters" },
                    uniqueness: { scope: :course_id, message: "already exists for this course" }
  validates :location, presence: { message: "Location is required - please select a building" }, length: { maximum: 150 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  validate :study_group_duration_reasonable
  validate :study_group_duration_minimum
  validate :creator_study_group_limit

  # Scopes
  scope :upcoming, -> { where("end_time > ?", Time.current).order(start_time: :asc) }
  scope :past, -> { where("end_time < ?", Time.current).order(start_time: :desc) }

  # Methods
  def member_count
    group_memberships.count
  end

  def member_ids
    group_memberships.pluck(:student_id)
  end

  def duration_minutes
    return nil unless start_time && end_time
    ((end_time - start_time) / 60).to_i
  end

  def status
    return "past" if end_time < Time.current
    return "ongoing" if start_time <= Time.current && end_time >= Time.current
    "upcoming"
  end

  def formatted_time_range
    return "" unless start_time && end_time
    if start_time.to_date == end_time.to_date
      "#{start_time.strftime('%A, %b %d, %Y at %I:%M %p')} - #{end_time.strftime('%I:%M %p')}"
    else
      "#{start_time.strftime('%A, %b %d at %I:%M %p')} - #{end_time.strftime('%A, %b %d at %I:%M %p')}"
    end
  end

  private

  def add_creator_membership
    return unless creator_id.present?

    GroupMembership.find_or_create_by(student_id: creator_id, group_id: group_id)
  end

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def topic_is_appropriate
    # TODO: Implement comprehensive profanity filter in the future
    # For now, assume topic is appropriate
  end



  def study_group_duration_reasonable
    return if start_time.blank? || end_time.blank?

    duration_hours = ((end_time - start_time) / 3600).to_i
    max_duration_hours = 6

    if duration_hours > max_duration_hours
      errors.add(:end_time, "study group cannot last more than #{max_duration_hours} hours")
    end
  end

  def study_group_duration_minimum
    return if start_time.blank? || end_time.blank?

    duration_minutes = ((end_time - start_time) / 60).to_i
    min_duration_minutes = 15

    if duration_minutes < min_duration_minutes
      errors.add(:end_time, "study group must be at least #{min_duration_minutes} minutes long")
    end
  end

  def creator_study_group_limit
    return if creator_id.blank?

    max_study_groups = 5
    creator_study_groups = StudyGroup.where(creator_id: creator_id).count

    if creator_study_groups >= max_study_groups
      errors.add(:base, "You have reached the maximum of #{max_study_groups} study groups you can create")
    end
  end
end
