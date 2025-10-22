class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :ensure_current_student

  helper_method :current_student, :current_student_id

  private

  def ensure_current_student
    return if session[:student_id].present?

    session[:student_id] = Student.order(:name).first&.student_id
  end

  def current_student_id
    normalize_student_id(session[:student_id])
  end

  def current_student
    return @current_student if defined?(@current_student)

    @current_student = Student.find_by(student_id: current_student_id)
  end

  def normalize_student_id(value)
    return value if value.is_a?(Integer)
    return if value.blank?

    Integer(value)
  rescue ArgumentError, TypeError
    nil
  end
end
