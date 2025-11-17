class MapController < ApplicationController
  def index
    # Disable caching for this page
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    
    @student = current_student
    
    # Get all upcoming study groups the student is a member of
    @study_groups = @student.study_groups.upcoming.includes(:course, :creator).order(start_time: :asc)
    
    # Prepare locations data for the map
    @locations = @study_groups.map do |group|
      next unless group.location.present?
      
      coords = location_to_coordinates(group.location)
      next unless coords
      
      {
        id: group.group_id,
        coordinates: coords,
        location: group.location,
        topic: group.topic,
        course: group.course.course_name,
        start_time: group.start_time,
        end_time: group.end_time,
        formatted_time: group.formatted_time_range,
        url: study_group_path(group)
      }
    end.compact
  end

  private

  # Map building name directly to coordinates
  # Building names come from the dropdown selection, so no regex needed
  def location_to_coordinates(location)
    return nil if location.blank?
    
    # Default coordinates for Evanston, IL (Northwestern University area)
    default_coords = [42.0565, -87.6753]
    
    # Direct mapping of building names to coordinates
    building_coords = building_name_to_coordinates(location)
    
    building_coords || default_coords
  end

  # Map building name to coordinates
  # Northwestern University campus buildings in Evanston, IL
  def building_name_to_coordinates(building_name)
    return nil if building_name.blank?
    
    # Direct mapping of building names to coordinates
    building_map = {
      "Tech Building" => [42.057788, -87.675909],
      "Main Library" => [42.053198, -87.67404],
      "Deering Library" => [42.053225, -87.675249],
      "Mudd Library" => [42.058128, -87.674357],
      "Ford" => [42.056872, -87.676555]
    }
    
    # Direct lookup - case insensitive
    building_map[building_name] || building_map.find { |key, _| key.casecmp?(building_name) }&.last
  end
end

