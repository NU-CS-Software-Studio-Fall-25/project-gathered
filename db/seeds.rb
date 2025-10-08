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
require "faker"

ActiveRecord::Base.transaction do
  # 0) Clean slate (dev only)
  tables = %w[group_memberships student_courses study_groups courses students]
  ApplicationRecord.connection.execute("TRUNCATE #{tables.join(', ')} RESTART IDENTITY CASCADE")

  # 1) Students
  STUDENT_COUNT = 150
  students = Array.new(STUDENT_COUNT) do
    Student.create!(name: Faker::Name.name)
  end

  # 2) Courses
  course_specs = [
    ["COMP_SCI 110 – Intro to CS",    "Programming fundamentals",         "Prof. Lee"],
    ["COMP_SCI 211 – Fund. II",       "Data structures & recursion",      "Prof. Chen"],
    ["COMP_SCI 214 – Data Structures","Abstract data types & analysis",   "Prof. Patel"],
    ["COMP_SCI 340 – Networking",     "Computer networks & Wireshark",    "Prof. Ghena"],
    ["IEMS 341 – Social Networks",    "Network models & inference",       "Prof. Hammond"],
    ["MATH 240 – Linear Algebra",     "Matrices, eigenvalues, eigvecs",   "Prof. Nguyen"],
    ["STAT 350 – Regression",         "Applied linear models",            "Prof. Kim"]
  ]
  courses = course_specs.map do |name, desc, prof|
    Course.create!(course_name: name, description: desc, professor: prof)
  end

  # 3) Study groups per course
  topics = {
    "COMP_SCI 340 – Networking" => ["DNS Proxy project", "TCP vs UDP review", "Wireshark lab prep"],
    "IEMS 341 – Social Networks"=> ["ERGM practice", "RSiena walkthrough", "Modularity & community"],
    "MATH 240 – Linear Algebra"  => ["SVD practice", "Eigenvalues jam", "Problem set review"]
  }
  groups = []
  courses.each do |course|
    rand(2..5).times do
      creator = students.sample
      topic   = (topics[course.course_name] || ["Homework review", "Midterm prep", "Project kickoff"]).sample

      start = Time.current + rand(1..30).days + rand(10..19).hours
      finish = start + rand(60..150).minutes

      groups << StudyGroup.create!(
        course_id:   course.course_id,
        creator_id:  creator.student_id,
        topic:       topic,
        description: Faker::Lorem.sentence(word_count: 14),
        location:    "#{Faker::Educator.campus} Room #{rand(100..499)}",
        start_time:  start,
        end_time:    finish
      )
    end
  end

  # 4) Enroll students into courses (student_courses)
  courses.each do |course|
    enrolled = students.sample(rand(30..60)) # unique by default
    enrolled.each do |stu|
      StudentCourse.create!(student_id: stu.student_id, course_id: course.course_id)
    end
  end

  # 5) Group memberships (only from students enrolled in that course)
  groups.each do |grp|
    enrolled_ids = StudentCourse.where(course_id: grp.course_id).pluck(:student_id)
    next if enrolled_ids.empty?

    member_ids = enrolled_ids.sample([rand(8..20), enrolled_ids.size].min)
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
