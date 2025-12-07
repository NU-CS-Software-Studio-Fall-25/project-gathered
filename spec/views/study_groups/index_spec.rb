require 'rails_helper'

RSpec.describe "study_groups/index", type: :view do
  let(:course) { create(:course, course_name: 'COMP_SCI 211', course_code: 'COMP_SCI_211') }
  let(:creator) { create(:student) }
  
  it 'displays study group date with day of week when viewing course study groups' do
    study_group = create(:study_group,
      course: course,
      creator: creator,
      topic: 'Lab session',
      start_time: Time.zone.parse('2025-11-23 00:38'),
      end_time: Time.zone.parse('2025-11-23 02:38')
    )
    
    assign(:study_groups, [study_group])
    assign(:course, course)
    
    render
    
    expect(rendered).to match(/Sunday.*Nov 23, 2025/)
  end

  it 'displays day of week for study groups on different days' do
    study_group = create(:study_group,
      course: course,
      creator: creator,
      topic: 'Final Exam Prep',
      start_time: Time.zone.parse('2025-12-08 14:00'),
      end_time: Time.zone.parse('2025-12-08 16:00')
    )
    
    assign(:study_groups, [study_group])
    assign(:course, course)
    
    render
    
    expect(rendered).to match(/Monday.*Dec 8, 2025/)
  end
end
