class StudentSessionsController < ApplicationController
  skip_before_action :ensure_current_student, only: :create

  def create
    session[:student_id] = Student.find_by(student_id: params[:student_id])&.student_id

    redirect_back fallback_location: root_path, notice: "Signed in as #{current_student&.name || 'Student'}"
  end
end
