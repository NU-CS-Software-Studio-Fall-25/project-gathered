class GroupMembership < ApplicationRecord
  # This table has no primary key
  self.primary_key = nil

  # Associations
  belongs_to :student, primary_key: :student_id, foreign_key: :student_id
  belongs_to :group, class_name: "StudyGroup", primary_key: :group_id, foreign_key: :group_id

  # Validations
  validates :student_id, uniqueness: { scope: :group_id, message: "already a member of this group" }
end
