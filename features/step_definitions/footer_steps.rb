# frozen_string_literal: true

Given("I am on the GatherEd application") do
  @student = Student.find_or_create_by!(email: "cuke@example.com") do |s|
    s.name = "Cuke User"
    s.password = "password123"
    s.password_confirmation = "password123"
  end

  visit login_path
  fill_in "Email", with: @student.email
  fill_in "Password", with: "password123"
  click_button "Sign In"
end

When("I visit the dashboard page") do
  visit dashboard_path
end

When("I visit the search page") do
  visit search_path
end

When("I visit the my groups page") do
  visit my_groups_path
end

When("I visit the calendar page") do
  visit calendar_path
end

When("I visit the map page") do
  visit map_path
end

When("I visit any page") do
  visit dashboard_path
end

Then("I should see a footer") do
  expect(page).to have_css("footer")
end

Then("the footer should contain {string}") do |text|
  within("footer") do
    expect(page).to have_content(text)
  end
end

Then("I should see the GatherEd logo in the footer") do
  within("footer") do
    expect(page).to have_content("GatherEd")
  end
end

Then("the footer should contain copyright information") do
  within("footer") do
    expect(page).to have_content("©")
  end
end

Then("the footer should display the current year") do
  within("footer") do
    expect(page).to have_content(Time.current.year.to_s)
  end
end

When("I click on {string} in the footer") do |link|
  within("footer") do
    click_link link
  end
end

Then("I should be redirected to the search page") do
  expect(page).to have_current_path(search_path)
end
