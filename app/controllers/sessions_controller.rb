class SessionsController < ApplicationController
  skip_before_action :authenticate_student!, only: [:new, :create, :google_auth, :failure]
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
        # Email doesn't exist, show message on login page instead of redirecting
        @student = Student.new(email: session_params[:email])
        flash.now[:alert] = "No account found with this email"
        render :new, status: :unprocessable_entity
      end
    end
  end

  def destroy
    session[:student_id] = nil
    redirect_to login_path, notice: "You have been logged out"
  end

  def google_auth
    auth = request.env["omniauth.auth"]

    unless auth
      redirect_to login_path, alert: "Google authentication data was not provided. Please try again."
      return
    end

    @student = Student.from_omniauth(auth)
    session[:student_id] = @student.student_id

    redirect_to dashboard_path, notice: "Signed in as #{@student.name}"
  rescue StandardError => e
    Rails.logger.error("Google OAuth sign in failed: #{e.class} - #{e.message}")
    redirect_to login_path, alert: "We couldn't sign you in with Google. Please try again or use your password."
  end

  def failure
    message = params[:message].presence || "Authentication failed"
    redirect_to login_path, alert: "Google sign in failed: #{message.tr('_', ' ')}"
  end

  private

  def session_params
    params.require(:student).permit(:email, :password)
  end

  def redirect_if_logged_in
    redirect_to root_path if current_student
  end
end
