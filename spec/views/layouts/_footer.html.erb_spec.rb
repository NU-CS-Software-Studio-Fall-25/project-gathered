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
  it "lists the creators" do
    expect(rendered).to have_content('Created by')
    %w[Alex Anca Daniel Wong Ellis Mandel Matthew Song].each do |name|
      expect(rendered).to have_content(name)
    end
  end
end
