class CalendarController < ApplicationController
  def index
    # Get the start date from params or use today
    @start_date = params.fetch(:start_date, Date.today).to_date

    # Get ALL study groups that the current user has joined (including past ones)
    # We need to load groups within the calendar view range for better performance
    start_of_calendar = @start_date.beginning_of_month.beginning_of_week
    end_of_calendar = @start_date.end_of_month.end_of_week

    @study_groups = StudyGroup
      .joins(:group_memberships)
      .where(group_memberships: { student_id: current_student.student_id })
      .where(start_time: start_of_calendar..end_of_calendar)
      .includes(:course, :creator)
      .order(:start_time)
  end
end
