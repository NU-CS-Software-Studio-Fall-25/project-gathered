# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

SEED_PASSWORD = "password123".freeze

students_data = [
  { name: "Alice Johnson", email: "alice@example.com" },
  { name: "Bob Smith", email: "bob@example.com" },
  { name: "Carol Davis", email: "carol@example.com" },
  { name: "David Wilson", email: "david@example.com" },
  { name: "Eve Brown", email: "eve@example.com" },
  { name: "Frank Miller", email: "frank@example.com" },
  { name: "Grace Lee", email: "grace@example.com" },
  { name: "Henry Taylor", email: "henry@example.com" },
  { name: "Ivy Chen", email: "ivy@example.com" },
  { name: "Jack Anderson", email: "jack@example.com" }
]

courses_data = [
  { course_name: "COMP_SCI 110 – Intro to CS", description: "Programming fundamentals", professor: "Prof. Lee" },
  { course_name: "COMP_SCI 211 – Fund. II", description: "Data structures & recursion", professor: "Prof. Chen" },
  { course_name: "COMP_SCI 214 – Data Structures", description: "Abstract data types & analysis", professor: "Prof. Patel" },
  { course_name: "COMP_SCI 340 – Networking", description: "Computer networks & Wireshark", professor: "Prof. Ghena" },
  { course_name: "IEMS 341 – Social Networks", description: "Network models & inference", professor: "Prof. Hammond" },
  { course_name: "MATH 240 – Linear Algebra", description: "Matrices, eigenvalues, eigvecs", professor: "Prof. Nguyen" },
  { course_name: "STAT 350 – Regression", description: "Applied linear models", professor: "Prof. Kim" }
]

topics = ["Homework review", "Midterm prep", "Project kickoff", "Lab session", "Exam review"]

ActiveRecord::Base.transaction do
  # Only wipe data in dev/test to keep prod safe
  if Rails.env.development? || Rails.env.test?
    tables = %w[group_memberships student_courses study_groups courses students]
    ApplicationRecord.connection.execute("TRUNCATE #{tables.join(', ')} RESTART IDENTITY CASCADE")
  end

  students = students_data.map do |attrs|
    Student.find_or_create_by!(email: attrs[:email]) do |s|
      s.name = attrs[:name]
      s.password = SEED_PASSWORD
      s.password_confirmation = SEED_PASSWORD
    end
  end

  courses = courses_data.map do |attrs|
    Course.find_or_create_by!(course_name: attrs[:course_name]) do |c|
      c.description = attrs[:description]
      c.professor   = attrs[:professor]
    end
  end

  groups = []
  courses.each_with_index do |course, course_idx|
    2.times do |i|
      creator = students[(course_idx + i) % students.size]
      topic   = topics[(course_idx + i) % topics.size]
      start   = Time.zone.now.change(min: 0, sec: 0) + (i + 1).days + 14.hours
      finish  = start + 2.hours

      groups << StudyGroup.find_or_create_by!(course_id: course.course_id, topic: topic) do |g|
        g.creator_id  = creator.student_id
        g.description = "Join us for a collaborative study session to review course material and prepare for upcoming assignments."
        g.location    = "Tech Building"
        g.start_time  = start
        g.end_time    = finish
      end
    end
  end

  courses.each_with_index do |course, idx|
    # Deterministic set of 5 students per course
    enrolled = students.rotate(idx).first(5)
    enrolled.each do |stu|
      StudentCourse.find_or_create_by!(student_id: stu.student_id, course_id: course.course_id)
    end
  end

  groups.each do |grp|
    enrolled_ids = StudentCourse.where(course_id: grp.course_id).pluck(:student_id)
    next if enrolled_ids.empty?

    member_ids = enrolled_ids.first([3, enrolled_ids.size].min)
    member_ids.each do |sid|
      GroupMembership.find_or_create_by!(student_id: sid, group_id: grp.group_id)
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
