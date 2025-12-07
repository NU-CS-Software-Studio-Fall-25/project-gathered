class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_student!, unless: -> { action_name == "not_found" }

  helper_method :current_student, :current_student_id, :logged_in?

  # 404 handler for catch-all routes
  def not_found
    respond_to do |format|
      format.html { render file: Rails.public_path.join("404.html"), status: :not_found, layout: false }
      format.json { render json: { error: "Not found" }, status: :not_found }
      format.any { head :not_found }
    end
  end

  private

  def authenticate_student!
    return if logged_in?

    redirect_to login_path, alert: "Please log in to access this page"
  end

  def current_student_id
    normalize_student_id(session[:student_id])
  end

  def current_student
    return @current_student if defined?(@current_student)

    @current_student = Student.find_by(student_id: current_student_id)
  end

  def logged_in?
    current_student.present?
  end

  def normalize_student_id(value)
    return value if value.is_a?(Integer)
    return if value.blank?

    Integer(value)
  rescue ArgumentError, TypeError
    nil
  end
end
