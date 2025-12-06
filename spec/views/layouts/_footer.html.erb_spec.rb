require 'rails_helper'

RSpec.describe "layouts/_footer", type: :view do
  before do
    render partial: "layouts/footer"
  end

  it "renders the footer element" do
    expect(rendered).to have_css('footer')
  end

  it "displays GatherEd logo or branding" do
    expect(rendered).to have_content('GatherEd')
  end

  it "displays copyright with current year" do
    expect(rendered).to have_content("© #{Time.current.year} GatherEd")
  end

  it "displays Dashboard link" do
    expect(rendered).to have_link('Dashboard', href: dashboard_path)
  end

  it "displays Search link" do
    expect(rendered).to have_link('Search', href: search_path)
  end

  it "displays My Groups link" do
    expect(rendered).to have_link('My Groups', href: my_groups_path)
  end

  it "displays Calendar link" do
    expect(rendered).to have_link('Calendar', href: calendar_path)
  end

  it "displays Map link" do
    expect(rendered).to have_link('Map', href: map_path)
  end
end
