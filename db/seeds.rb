# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb
# Simple seed data for production deployment

ActiveRecord::Base.transaction do
  # 0) Clean slate (dev only)
  tables = %w[group_memberships student_courses study_groups courses students]
  ApplicationRecord.connection.execute("TRUNCATE #{tables.join(', ')} RESTART IDENTITY CASCADE")

  # 1) Students
  students = [
    Student.create!(name: "Alice Johnson"),
    Student.create!(name: "Bob Smith"),
    Student.create!(name: "Carol Davis"),
    Student.create!(name: "David Wilson"),
    Student.create!(name: "Eve Brown"),
    Student.create!(name: "Frank Miller"),
    Student.create!(name: "Grace Lee"),
    Student.create!(name: "Henry Taylor"),
    Student.create!(name: "Ivy Chen"),
    Student.create!(name: "Jack Anderson")
  ]

  # 2) Courses
  courses = [
    Course.create!(course_name: "COMP_SCI 110 – Intro to CS", description: "Programming fundamentals", professor: "Prof. Lee"),
    Course.create!(course_name: "COMP_SCI 211 – Fund. II", description: "Data structures & recursion", professor: "Prof. Chen"),
    Course.create!(course_name: "COMP_SCI 214 – Data Structures", description: "Abstract data types & analysis", professor: "Prof. Patel"),
    Course.create!(course_name: "COMP_SCI 340 – Networking", description: "Computer networks & Wireshark", professor: "Prof. Ghena"),
    Course.create!(course_name: "IEMS 341 – Social Networks", description: "Network models & inference", professor: "Prof. Hammond"),
    Course.create!(course_name: "MATH 240 – Linear Algebra", description: "Matrices, eigenvalues, eigvecs", professor: "Prof. Nguyen"),
    Course.create!(course_name: "STAT 350 – Regression", description: "Applied linear models", professor: "Prof. Kim")
  ]

  # 3) Study groups per course
  groups = []
  courses.each do |course|
    2.times do |i|
      creator = students.sample
      topics = ["Homework review", "Midterm prep", "Project kickoff", "Lab session", "Exam review"]
      topic = topics.sample

      start = Time.current + (i + 1).days + 14.hours
      finish = start + 2.hours

      groups << StudyGroup.create!(
        course_id:   course.course_id,
        creator_id:  creator.student_id,
        topic:       topic,
        description: "Join us for a collaborative study session to review course material and prepare for upcoming assignments.",
        location:    "Tech Building Room #{100 + i * 50}",
        start_time:  start,
        end_time:    finish
      )
    end
  end

  # 4) Enroll students into courses (student_courses)
  courses.each do |course|
    enrolled = students.sample(5) # 5 students per course
    enrolled.each do |stu|
      StudentCourse.create!(student_id: stu.student_id, course_id: course.course_id)
    end
  end

  # 5) Group memberships (only from students enrolled in that course)
  groups.each do |grp|
    enrolled_ids = StudentCourse.where(course_id: grp.course_id).pluck(:student_id)
    next if enrolled_ids.empty?

    member_ids = enrolled_ids.sample([3, enrolled_ids.size].min)
    member_ids.each do |sid|
      GroupMembership.create!(student_id: sid, group_id: grp.group_id)
    end
  end
end

puts({
  students: Student.count,
  courses: Course.count,
  study_groups: StudyGroup.count,
  enrollments: StudentCourse.count,
  memberships: GroupMembership.count
})
