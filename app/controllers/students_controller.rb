class StudentsController < ApplicationController
  before_action :set_student, only: [ :show, :edit, :update ]

  def show
    @study_groups = @student.study_groups.includes(:course, :creator).order("study_groups.start_time DESC")
    @created_groups = @student.created_study_groups.includes(:course).order(start_time: :desc)
  end

  def edit
  end

  def update
    if @student.update(student_params)
      respond_to do |format|
        format.html { redirect_to student_path(@student), notice: "Profile updated successfully!" }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "student_profile_header",
              partial: "students/profile_header",
              locals: { student: @student }
            ),
            turbo_stream.prepend(
              "flash_messages",
              partial: "shared/flash",
              locals: { message: "Profile updated successfully!", type: "success" }
            )
          ]
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:name)
  end
end
