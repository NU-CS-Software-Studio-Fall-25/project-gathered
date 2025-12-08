require "test_helper"

class StudyGroupTest < ActiveSupport::TestCase
  test "formatted_time_range includes day of week for same-day events" do
    study_group = StudyGroup.new(
      start_time: Time.new(2025, 12, 16, 18, 30, 0), # Tuesday, Dec 16, 2025 at 6:30 PM
      end_time: Time.new(2025, 12, 16, 20, 0, 0)     # Tuesday, Dec 16, 2025 at 8:00 PM
    )
    
    expected_format = "Tuesday, Dec 16, 2025 at 06:30 PM - 08:00 PM"
    assert_equal expected_format, study_group.formatted_time_range
  end

  test "formatted_time_range includes day of week for multi-day events" do
    study_group = StudyGroup.new(
      start_time: Time.new(2025, 12, 16, 18, 30, 0), # Tuesday, Dec 16
      end_time: Time.new(2025, 12, 17, 20, 0, 0)     # Wednesday, Dec 17
    )
    
    expected_format = "Tuesday, Dec 16 at 06:30 PM - Wednesday, Dec 17 at 08:00 PM"
    assert_equal expected_format, study_group.formatted_time_range
  end

  test "formatted_time_range returns empty string when times are nil" do
    study_group = StudyGroup.new(start_time: nil, end_time: nil)
    assert_equal "", study_group.formatted_time_range
  end

  test "formatted_time_range handles different days of the week correctly" do
    # Test Sunday
    study_group = StudyGroup.new(
      start_time: Time.new(2025, 12, 14, 10, 0, 0), # Sunday, Dec 14, 2025
      end_time: Time.new(2025, 12, 14, 12, 0, 0)
    )
    assert_match /^Sunday, Dec 14, 2025/, study_group.formatted_time_range

    # Test Friday
    study_group = StudyGroup.new(
      start_time: Time.new(2025, 12, 19, 10, 0, 0), # Friday, Dec 19, 2025
      end_time: Time.new(2025, 12, 19, 12, 0, 0)
    )
    assert_match /^Friday, Dec 19, 2025/, study_group.formatted_time_range
  end
end
