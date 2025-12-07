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
      expect(page).to have_content('Created by')
    end

    it "displays footer on search page" do
      visit search_path

      expect(page).to have_css('footer')
      expect(page).to have_content('Created by')
    end

    it "displays footer on my groups page" do
      visit my_groups_path

      expect(page).to have_css('footer')
      expect(page).to have_content('Created by')
    end

    it "displays footer on calendar page" do
      visit calendar_path

      expect(page).to have_css('footer')
      expect(page).to have_content('Created by')
    end

    it "displays footer on map page" do
      visit map_path

      expect(page).to have_css('footer')
      expect(page).to have_content('Created by')
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

    it "lists the creators" do
      visit dashboard_path

      within('footer') do
        expect(page).to have_content('Created by')
        %w[Alex Anca Daniel Wong Ellis Mandel Matthew Song].each do |name|
          expect(page).to have_content(name)
        end
      end
    end
  end
end
