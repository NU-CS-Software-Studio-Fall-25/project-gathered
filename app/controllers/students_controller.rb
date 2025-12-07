class StudentsController < ApplicationController
  skip_before_action :authenticate_student!, only: [ :new, :create ]
  before_action :redirect_if_logged_in, only: [ :new, :create ]

  def new
    @student = Student.new
    # Pre-fill email if provided via params (from login page)
    @student.email = params[:email] if params[:email].present?
  end

  def create
    # Check if email already exists before attempting to save
    if Student.exists?(email: student_params[:email])
      redirect_to login_path(email: student_params[:email])
      return
    end

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

  def toggle_high_contrast
    current_student.update(high_contrast: params[:high_contrast])
    head :ok
  end

  def update_avatar_color
    current_student.update(avatar_color: params[:avatar_color])
    head :ok
  end

  private

  def student_params
    params.require(:student).permit(:name, :email, :password, :password_confirmation, :avatar_color, :high_contrast)
  end

  def redirect_if_logged_in
    redirect_to root_path if current_student
  end
end
