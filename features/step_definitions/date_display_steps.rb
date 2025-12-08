Given('I am logged in as a student') do
  # Load seed data if not already loaded
  load Rails.root.join('db', 'seeds.rb') unless Student.exists?(email: 'alice@example.com')
  
  # Visit login page and sign in
  visit login_path
  fill_in "Email", with: "alice@example.com"
  fill_in "Password", with: "password123"
  click_button "Sign In"
end

When('I visit the course page for {string} at {string}') do |course_name, path|
  visit path
end

Then('I should see a study group called {string}') do |study_group_name|
  expect(page).to have_content(study_group_name)
end

Then('I should see {string} as the study group date') do |date_string|
  expect(page).to have_content(date_string)
end
