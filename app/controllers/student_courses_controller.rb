class StudentCoursesController < ApplicationController
  def create
    course_id = params.dig(:student_course, :course_id)
    @course = Course.find(course_id)
    @student_course = current_student.student_courses.build(course_id: @course.course_id)

    if @student_course.save
      respond_to do |format|
        format.html { redirect_back fallback_location: courses_path, notice: "Successfully enrolled in #{@course.course_name}" }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: courses_path, alert: @student_course.errors.full_messages.first }
        format.turbo_stream { render turbo_stream: turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { message: @student_course.errors.full_messages.first, type: "error" }) }
      end
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_back fallback_location: courses_path, alert: "Course not found" }
      format.turbo_stream { render turbo_stream: turbo_stream.prepend("flash_messages", partial: "shared/flash", locals: { message: "Course not found", type: "error" }) }
    end
  end

  def destroy
    @course = Course.find(params[:id])
    
    # First, remove student from all study groups for this course
    study_group_ids = @course.study_groups.pluck(:group_id)
    GroupMembership.where(
      student_id: current_student.student_id,
      group_id: study_group_ids
    ).delete_all
    
    # Then, unenroll from the course
    deleted_count = StudentCourse.where(
      student_id: current_student.student_id,
      course_id: @course.course_id
    ).delete_all
    
    if deleted_count > 0
      respond_to do |format|
        format.html { redirect_to courses_path, notice: "Successfully unenrolled from #{@course.course_name}" }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to courses_path, alert: "Could not unenroll from course" }
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend(
            "flash_messages",
            partial: "shared/flash",
            locals: { message: "Could not unenroll from course", type: "error" }
          )
        end
      end
    end
  end
end
