require "icalendar"

class StudyGroupsController < ApplicationController
  before_action :set_study_group, only: [ :show, :edit, :update, :destroy, :join, :leave, :export_ics ]
  before_action :set_course, only: [ :index, :new, :create ]

  def index
    @study_groups = @course.study_groups.includes(:creator, :group_memberships).order(start_time: :asc)
  end

  def export_ics
    authorize_group_export!

    respond_to do |format|
      format.ics do
        send_data build_ics_calendar,
                  type: "text/calendar; charset=utf-8",
                  disposition: "attachment",
                  filename: sanitized_filename
      end
      format.html { redirect_to study_group_path(@study_group) }
    end
  end

  def show
    @members = @study_group.members.order(:name)
  end

  def new
    if params[:restore_button]
      render partial: "study_groups/create_button", locals: { course: @course }, layout: false
    else
      @study_group = @course.study_groups.build
    end
  end

  def create
    @study_group = @course.study_groups.build(study_group_params)

    respond_to do |format|
      if @study_group.save
        # Creator is automatically added as a member via after_create_commit callback in StudyGroup model

        format.html { redirect_to course_path(@course), notice: "Study group created successfully!" }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @study_group.update(study_group_params)
      respond_to do |format|
        format.html { redirect_to study_group_path(@study_group), notice: "Study group updated!" }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "study_group_#{@study_group.group_id}",
            partial: "study_groups/study_group",
            locals: { study_group: @study_group }
          )
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    course = @study_group.course
    @study_group.destroy

    respond_to do |format|
      format.html { redirect_to course_path(course), notice: "Study group deleted." }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("study_group_#{@study_group.group_id}"),
          turbo_stream.prepend(
            "flash_messages",
            partial: "shared/flash",
            locals: { message: "Study group deleted.", type: "info" }
          )
        ]
      end
    end
  end

  def join
    student_id = determine_student_id

    if student_id && !@study_group.member_ids.include?(student_id)
      GroupMembership.create!(student_id: student_id, group_id: @study_group.group_id)
      @study_group.reload

      respond_to do |format|
        format.html { redirect_to course_path(@study_group.course), notice: "You joined the study group!" }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "study_group_#{@study_group.group_id}",
              partial: "study_groups/study_group",
              locals: { study_group: @study_group, current_student_id: student_id }
            ),
            turbo_stream.replace(
              "study_group_actions",
              partial: "study_groups/detail_actions",
              locals: { study_group: @study_group, current_student_id: student_id }
            ),
            turbo_stream.replace(
              "study_group_members",
              partial: "study_groups/members_list",
              locals: { study_group: @study_group, members: @study_group.members.order(:name) }
            )
          ]
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to course_path(@study_group.course), alert: "Could not join group." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend(
            "flash_messages",
            partial: "shared/flash",
            locals: { message: "Could not join group.", type: "error" }
          )
        end
      end
    end
  end

  def leave
    student_id = determine_student_id

    if student_id

      GroupMembership.where(student_id: student_id, group_id: @study_group.group_id).delete_all
      @study_group.reload

      if @study_group.members.count == 0
        course = @study_group.course
        @study_group.destroy

        redirect_path = course_path(course)
        if params[:return_to].present?
          # Prevent redirect loop if return_to is the deleted group page
          redirect_path = params[:return_to] unless params[:return_to].include?(study_group_path(@study_group))
        end

        respond_to do |format|
          format.html { redirect_to redirect_path, notice: "Study group deleted as it has no members." }
          format.turbo_stream do
            if params[:source] == "detail"
              # If we are on the detail page, we MUST redirect away
              redirect_to redirect_path, notice: "Study group deleted as it has no members."
            else
              # If we are on the list page, we can just remove the element
              render turbo_stream: [
                turbo_stream.remove("study_group_#{@study_group.group_id}"),
                turbo_stream.prepend(
                  "flash_messages",
                  partial: "shared/flash",
                  locals: { message: "Study group deleted as it has no members.", type: "info" }
                )
              ]
            end
          end
        end
        return
      end

      respond_to do |format|
        format.html {
          redirect_back fallback_location: course_path(@study_group.course), notice: "You left the study group."
        }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "study_group_#{@study_group.group_id}",
              partial: "study_groups/study_group",
              locals: { study_group: @study_group, current_student_id: student_id }
            ),
            turbo_stream.replace(
              "study_group_actions",
              partial: "study_groups/detail_actions",
              locals: { study_group: @study_group, current_student_id: student_id }
            ),
            turbo_stream.replace(
              "study_group_members",
              partial: "study_groups/members_list",
              locals: { study_group: @study_group, members: @study_group.members.order(:name) }
            )
          ]
        end
      end
    else
      respond_to do |format|
        format.html {
          redirect_back fallback_location: course_path(@study_group.course), alert: "Could not leave group."
        }
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend(
            "flash_messages",
            partial: "shared/flash",
            locals: { message: "Could not leave group.", type: "error" }
          )
        end
      end
    end
  end

  private

  def set_study_group
    @study_group = StudyGroup.find(params[:id])
  end

  def set_course
    @course = Course.find(params[:course_id])
  end

  def determine_student_id
    normalize_student_id(params[:student_id]&.presence) || current_student_id
  end

  def study_group_params
    params.require(:study_group).permit(:creator_id, :topic, :description, :location, :start_time, :end_time)
  end

  def build_ics_calendar
    cal = Icalendar::Calendar.new
    event = Icalendar::Event.new
    event.dtstart = Icalendar::Values::DateTime.new(@study_group.start_time.in_time_zone("America/Chicago"), "tzid" => "America/Chicago")
    event.dtend = Icalendar::Values::DateTime.new(@study_group.end_time.in_time_zone("America/Chicago"), "tzid" => "America/Chicago")
    event.summary = @study_group.topic
    event.description = @study_group.description.presence || "Study group for #{@study_group.course.course_name}"
    event.location = @study_group.location if @study_group.location.present?
    event.url = study_group_url(@study_group)
    event.uid = "study_group-#{@study_group.group_id}@gathered"
    cal.add_event(event)
    cal.publish
    cal.to_ical
  end

  def sanitized_filename
    base = @study_group.topic.presence || "study-group-#{@study_group.group_id}"
    normalized = base.parameterize(separator: "-")
    "#{normalized.presence || "study-group"}-#{@study_group.group_id}.ics"
  end

  def authorize_group_export!
    return if logged_in? && @study_group

    redirect_to login_path, alert: "Please sign in to download this event."
  end
end
