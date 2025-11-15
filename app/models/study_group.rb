class StudyGroup < ApplicationRecord
  # Associations
  belongs_to :course, primary_key: :course_id, foreign_key: :course_id
  belongs_to :creator, class_name: "Student", primary_key: :student_id, foreign_key: :creator_id
  has_many :group_memberships, primary_key: :group_id, foreign_key: :group_id, dependent: :destroy
  has_many :members, through: :group_memberships, source: :student

  after_create_commit :add_creator_membership

  # Validations
  validates :topic, presence: true, length: { maximum: 150 }
  validates :location, length: { maximum: 150 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  # Scopes
  scope :upcoming, -> { where("start_time > ?", Time.current).order(start_time: :asc) }
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
      "#{start_time.strftime('%b %d, %Y at %I:%M %p')} - #{end_time.strftime('%I:%M %p')}"
    else
      "#{start_time.strftime('%b %d at %I:%M %p')} - #{end_time.strftime('%b %d at %I:%M %p')}"
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
end
