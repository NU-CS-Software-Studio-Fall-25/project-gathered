require 'rails_helper'

RSpec.describe "Footer", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { create(:user) }

  before do
    sign_in user
  end

  context "when visiting any page" do
    it "displays footer on dashboard page" do
      visit dashboard_path

      expect(page).to have_css('footer')
      expect(page).to have_content('GatherEd')
      expect(page).to have_content("© #{Time.current.year}")
      expect(page).to have_link('Dashboard')
      expect(page).to have_link('Search')
      expect(page).to have_link('My Groups')
      expect(page).to have_link('Calendar')
      expect(page).to have_link('Map')
    end

    it "displays footer on search page" do
      visit search_path

      expect(page).to have_css('footer')
      expect(page).to have_link('Dashboard')
    end

    it "displays footer on my groups page" do
      visit my_groups_path

      expect(page).to have_css('footer')
      expect(page).to have_link('Search')
    end

    it "displays footer on calendar page" do
      visit calendar_path

      expect(page).to have_css('footer')
      expect(page).to have_link('Calendar')
    end

    it "displays footer on map page" do
      visit map_path

      expect(page).to have_css('footer')
      expect(page).to have_link('Map')
    end
  end

  context "footer navigation" do
    it "navigates to dashboard when clicking Dashboard link" do
      visit search_path

      within('footer') do
        click_link 'Dashboard'
      end

      expect(current_path).to eq(dashboard_path)
    end

    it "navigates to search page when clicking Search link" do
      visit dashboard_path

      within('footer') do
        click_link 'Search'
      end

      expect(current_path).to eq(search_path)
    end

    it "navigates to my groups page when clicking My Groups link" do
      visit dashboard_path

      within('footer') do
        click_link 'My Groups'
      end

      expect(current_path).to eq(my_groups_path)
    end

    it "navigates to calendar page when clicking Calendar link" do
      visit dashboard_path

      within('footer') do
        click_link 'Calendar'
      end

      expect(current_path).to eq(calendar_path)
    end

    it "navigates to map page when clicking Map link" do
      visit dashboard_path

      within('footer') do
        click_link 'Map'
      end

      expect(current_path).to eq(map_path)
    end
  end

  context "footer styling and responsiveness" do
    it "footer is visible and properly positioned" do
      visit dashboard_path

      footer = find('footer')
      expect(footer).to be_visible
    end

    it "displays current year dynamically" do
      visit dashboard_path

      within('footer') do
        expect(page).to have_content(Time.current.year.to_s)
      end
    end
  end
end
