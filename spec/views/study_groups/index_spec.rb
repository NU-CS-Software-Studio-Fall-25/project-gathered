require 'rails_helper'

RSpec.describe "Date display with day of week", type: :system do
  before do
    driven_by(:rack_test)
    # Load seed data which includes COMP_SCI 211 and Lab session study group
    load Rails.root.join('db', 'seeds.rb')
  end

  it 'displays study group date with day of week when viewing course study groups' do
    # Sign in using seeded user credentials
    visit login_path
    fill_in "Email", with: "alice@example.com"
    fill_in "Password", with: "password123"
    click_button "Sign In"
    
    # Visit the COMP_SCI 110 course page directly (courses/1)
    visit course_path(1)
    
    # Verify the Homework review study group exists with the correct date format including day of week
    # The date should display as "Sunday, Nov 23, 2025 at 12:38 AM - 02:38 AM"
    # instead of just "Nov 23, 2025 at 12:38 AM - 02:38 AM"
    expect(page).to have_content('Homework review')
    expect(page).to have_content('Sunday, Nov 23, 2025 at 12:38 AM - 02:38 AM')
  end
end