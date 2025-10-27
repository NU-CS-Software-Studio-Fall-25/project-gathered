class DashboardController < ApplicationController
  def index
    @student = current_student
    @enrolled_courses = @student.courses.includes(:study_groups).order(:course_name)
    @my_study_groups = @student.study_groups.includes(:course, :creator).order(start_time: :asc)
    @upcoming_study_groups = @my_study_groups.upcoming.limit(5)
    @recent_study_groups = @my_study_groups.past.limit(3)
  end
end
