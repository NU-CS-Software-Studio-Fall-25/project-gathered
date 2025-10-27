class StudentsController < ApplicationController
  skip_before_action :authenticate_student!, only: [:new, :create]
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
    @student = Student.new
    # Pre-fill email if provided via params (from login page)
    @student.email = params[:email] if params[:email].present?
  end

  def create
    @student = Student.new(student_params)
    
    if @student.save
      session[:student_id] = @student.student_id
      redirect_to dashboard_path, notice: "Account created successfully! Welcome, #{@student.name}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @student = current_student
  end

  def edit
    @student = current_student
  end

  def update
    @student = current_student
    
    if @student.update(student_params)
      redirect_to student_path(@student), notice: "Profile updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def student_params
    params.require(:student).permit(:name, :email, :password, :password_confirmation)
  end

  def redirect_if_logged_in
    redirect_to root_path if current_student
  end
end
