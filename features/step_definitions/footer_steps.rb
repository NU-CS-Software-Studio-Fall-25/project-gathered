module NavigationHelpers
  include Rails.application.routes.url_helpers
end

World(NavigationHelpers)

Given('I am on the GatherEd application') do
  @current_student ||= Student.find_or_create_by!(email: 'footer_tester@example.com') do |student|
    student.name = 'Footer Tester'
    student.password = 'password123'
    student.password_confirmation = 'password123'
  end

  visit login_path
  fill_in 'Email', with: @current_student.email
  fill_in 'Password', with: 'password123'
  click_button 'Sign In'
end

When('I visit the dashboard page') do
  visit dashboard_path
end

When('I visit the search page') do
  visit search_path
end

When('I visit the my groups page') do
  visit my_groups_path
end

When('I visit the calendar page') do
  visit calendar_path
end

When('I visit the map page') do
  visit map_path
end

Then('I should see a footer') do
  expect(page).to have_css('footer')
end

Then('the footer should contain {string}') do |text|
  within('footer') do
    expect(page).to have_content(text)
  end
end

Then('the footer should display the current year') do
  within('footer') do
    expect(page).to have_content(Time.zone.now.year.to_s)
  end
end

Then('the footer should list the creators:') do |table|
  names = table.raw.flatten
  within('footer') do
    names.each do |name|
      expect(page).to have_content(name)
    end
  end
end
