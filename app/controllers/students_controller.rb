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
      @student = Student.new(student_params)
      @student.errors.add(:email, "is already registered. Please sign in instead.")
      render :new, status: :unprocessable_entity
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

  def verify_password
    @student = current_student
    if @student.authenticate(params[:password])
      render json: { valid: true }
    else
      render json: { valid: false }
    end
  end

  def update
    @student = current_student

    # If user is trying to change password, verify current password first
    if params[:student][:password].present?
      unless @student.authenticate(params[:student][:current_password])
        @student.errors.add(:current_password, "is incorrect")
        render :edit, status: :unprocessable_entity
        return
      end
    end

    # Handle avatar removal if user switches back to color mode
    if params[:student][:remove_avatar] == "1"
      @student.avatar.purge if @student.avatar.attached?
    end

    if @student.update(update_params)
      redirect_to student_path, notice: "Profile updated successfully!"
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

  def update_params
    # Don't include password fields if they're blank (user doesn't want to change password)
    # Email is not allowed to be changed
    if params[:student][:password].blank?
      params.require(:student).permit(:name, :avatar_color, :avatar)
    else
      params.require(:student).permit(:name, :password, :password_confirmation, :avatar_color, :avatar)
    end
  end

  def redirect_if_logged_in
    redirect_to root_path if current_student
  end
end
