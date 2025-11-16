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

  # 1) Students (avatar_color will be automatically set by the before_create callback)
  students = [
    Student.create!(name: "Alice Johnson", email: "alice@example.com", password: "password123"),
    Student.create!(name: "Bob Smith", email: "bob@example.com", password: "password123"),
    Student.create!(name: "Carol Davis", email: "carol@example.com", password: "password123"),
    Student.create!(name: "David Wilson", email: "david@example.com", password: "password123"),
    Student.create!(name: "Eve Brown", email: "eve@example.com", password: "password123"),
    Student.create!(name: "Frank Miller", email: "frank@example.com", password: "password123"),
    Student.create!(name: "Grace Lee", email: "grace@example.com", password: "password123"),
    Student.create!(name: "Henry Taylor", email: "henry@example.com", password: "password123"),
    Student.create!(name: "Ivy Chen", email: "ivy@example.com", password: "password123"),
    Student.create!(name: "Jack Anderson", email: "jack@example.com", password: "password123")
  ]

  # 2) Courses
  courses = [
    Course.create!(course_name: "COMP_SCI 110 – Intro to CS", description: "Programming fundamentals", professor: "Prof. Lee", start_date: Time.new(2025, 9, 16), end_date: Time.new(2025, 12, 13)),
    Course.create!(course_name: "COMP_SCI 211 – Fund. II", description: "Data structures & recursion", professor: "Prof. Chen", start_date: Time.new(2025, 9, 16), end_date: Time.new(2025, 12, 13)),
    Course.create!(course_name: "COMP_SCI 214 – Data Structures", description: "Abstract data types & analysis", professor: "Prof. Patel", start_date: Time.new(2025, 9, 16), end_date: Time.new(2025, 12, 13)),
    Course.create!(course_name: "COMP_SCI 340 – Networking", description: "Computer networks & Wireshark", professor: "Prof. Ghena", start_date: Time.new(2025, 9, 16), end_date: Time.new(2025, 12, 13)),
    Course.create!(course_name: "IEMS 341 – Social Networks", description: "Network models & inference", professor: "Prof. Hammond", start_date: Time.new(2025, 9, 16), end_date: Time.new(2025, 12, 13)),
    Course.create!(course_name: "MATH 240 – Linear Algebra", description: "Matrices, eigenvalues, eigvecs", professor: "Prof. Nguyen", start_date: Time.new(2025, 9, 16), end_date: Time.new(2025, 12, 13)),
    Course.create!(course_name: "STAT 350 – Regression", description: "Applied linear models", professor: "Prof. Kim", start_date: Time.new(2025, 9, 16), end_date: Time.new(2025, 12, 13))
  ]

  # 3) Study groups per course (respecting the 5 study groups per creator limit)
  groups = []
  study_group_count = 0
  creator_study_group_counts = {}
  
  courses.each do |course|
    2.times do |i|
      creator = students.sample
      
      # Ensure creator hasn't exceeded the 5 study group limit
      creator_study_group_counts[creator.student_id] ||= 0
      if creator_study_group_counts[creator.student_id] >= 5
        creator = students.find { |s| (creator_study_group_counts[s.student_id] || 0) < 5 }
        next unless creator
      end
      
      topics = ["Homework review", "Midterm prep", "Project kickoff", "Lab session", "Exam review"]
      topic = topics.sample

      start = Time.current + (i + 1).days + 14.hours
      finish = start + 2.hours

      groups << StudyGroup.create!(
        course_id:   course.course_id,
        creator_id:  creator.student_id,
        topic:       topic,
        description: "Join us for a collaborative study session to review course material and prepare for upcoming assignments.",
        location:    "Tech Building",
        start_time:  start,
        end_time:    finish
      )
      
      creator_study_group_counts[creator.student_id] += 1
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
