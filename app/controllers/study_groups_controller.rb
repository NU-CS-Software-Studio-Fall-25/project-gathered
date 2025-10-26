class StudyGroupsController < ApplicationController
  before_action :set_study_group, only: [ :show, :edit, :update, :destroy, :join, :leave ]
  before_action :set_course, only: [ :index, :new, :create ]

  def index
    @study_groups = @course.study_groups.includes(:creator, :group_memberships).order(start_time: :asc)
  end

  def show
    @members = @study_group.members.order(:name)
  end

  def new
    @study_group = @course.study_groups.build
  end

  def create
    @study_group = @course.study_groups.build(study_group_params)

    if @study_group.save
      respond_to do |format|
        format.html { redirect_to course_path(@course), notice: "Study group created successfully!" }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend(
              "study_groups_list",
              partial: "study_groups/study_group",
              locals: { study_group: @study_group }
            ),
            turbo_stream.update(
              "new_group_form",
              html: ""
            ),
            turbo_stream.prepend(
              "flash_messages",
              partial: "shared/flash",
              locals: { message: "Study group created successfully!", type: "success" }
            )
          ]
        end
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_group_form",
            partial: "study_groups/form",
            locals: { study_group: @study_group, course: @course }
          )
        end
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
    creator_id = @study_group.creator_id
    @study_group.destroy

    respond_to do |format|
      format.html do
        # If the request came from the profile page, redirect back there
        if request.referer&.include?("students/")
          redirect_to student_path(creator_id), notice: "Study group deleted."
        else
          redirect_to course_path(course), notice: "Study group deleted."
        end
      end
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
              locals: { study_group: @study_group }
            ),
            turbo_stream.replace(
              "study_group_members",
              partial: "study_groups/members_list",
              locals: { study_group: @study_group, members: @study_group.members.order(:name) }
            ),
            turbo_stream.prepend(
              "flash_messages",
              partial: "shared/flash",
              locals: { message: "You joined the study group!", type: "success" }
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

      respond_to do |format|
        format.html { redirect_to course_path(@study_group.course), notice: "You left the study group." }
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
              locals: { study_group: @study_group }
            ),
            turbo_stream.replace(
              "study_group_members",
              partial: "study_groups/members_list",
              locals: { study_group: @study_group, members: @study_group.members.order(:name) }
            ),
            turbo_stream.prepend(
              "flash_messages",
              partial: "shared/flash",
              locals: { message: "You left the study group.", type: "info" }
            )
          ]
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to course_path(@study_group.course), alert: "Could not leave group." }
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
end
