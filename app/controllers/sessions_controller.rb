class SessionsController < ApplicationController
  skip_before_action :authenticate_student!, only: [:new, :create]
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
    @student = Student.new
    # Pre-fill email if provided via params (from signup page)
    @student.email = params[:email] if params[:email].present?
  end

  def create
    @student = Student.authenticate(session_params[:email], session_params[:password])
    
    if @student
      session[:student_id] = @student.student_id
      redirect_to dashboard_path, notice: "Welcome back, #{@student.name}!"
    else
      # Check if email exists in database
      existing_student = Student.find_by(email: session_params[:email])
      
      if existing_student
        @student = Student.new(email: session_params[:email])
        flash.now[:alert] = "Invalid password for this email"
        render :new, status: :unprocessable_entity
      else
        # Email doesn't exist, redirect to signup with pre-filled email
        redirect_to signup_path(email: session_params[:email]), 
                    alert: "No account found with this email. Please create an account."
      end
    end
  end

  def destroy
    session[:student_id] = nil
    redirect_to login_path, notice: "You have been logged out"
  end

  private

  def session_params
    params.require(:student).permit(:email, :password)
  end

  def redirect_if_logged_in
    redirect_to root_path if current_student
  end
end
