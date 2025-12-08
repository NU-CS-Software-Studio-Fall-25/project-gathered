require 'rails_helper'

RSpec.describe "Date display with day of week", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { create(:student) }

  before do
    sign_in user
  end

  it 'displays study group date with day of week when viewing course study groups' do
    # Visit the search page
    visit search_path
    
    # Select COMP_SCI 211 from find courses
    select 'COMP_SCI 211', from: 'course_id'
    
    # Click "Click to view study groups"
    click_link 'Click to view study groups'
    
    # Verify the Lab session study group exists and has the correct date format with day of week
    expect(page).to have_content('Lab session')
    expect(page).to have_content('Sunday, Nov 23, 2025 at 12:38 AM - 02:38 AM')
  end
end