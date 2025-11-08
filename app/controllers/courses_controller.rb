class CoursesController < ApplicationController
  def index
    @courses = Course.includes(:study_groups).order(:course_name)
  end

  def show
    @course = Course.includes(study_groups: :group_memberships).find(params[:id])
    @study_groups = @course.study_groups.includes(:creator, :group_memberships).order(start_time: :asc)

    respond_to do |format|
      format.html do
        render layout: !params[:partial]
      end
      format.turbo_stream
    end
  end
end

