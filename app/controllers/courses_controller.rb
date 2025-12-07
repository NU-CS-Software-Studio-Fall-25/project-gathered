class CoursesController < ApplicationController
  def index
    @courses = Course.includes(:study_groups).order(:course_name)
  end

  def show
    @current_student_id = current_student&.student_id
    @course = Course.includes(study_groups: :group_memberships).find(params[:id])
    @study_groups = @course.study_groups.includes(:creator, :group_memberships).order(created_at: :desc).to_a
    @study_groups.sort_by! do |sg|
      priority = if sg.status == "ongoing"
                   0
      elsif sg.status == "upcoming" && sg.group_memberships.any? { |m| m.student_id == @current_student_id }
                   1
      elsif sg.status == "upcoming"
                   2
      else
                   3
      end
      [ priority, -sg.created_at.to_i ]
    end

    # Check if the current student is enrolled in the course
    @is_enrolled = current_student&.courses&.include?(@course)

    respond_to do |format|
      format.html do
        render layout: !params[:partial]
      end
      format.turbo_stream
    end
  end
end
