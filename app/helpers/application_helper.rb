module ApplicationHelper
  # Returns a list of buildings for dropdown selection
  def buildings_list
    [
      [ "Tech Building", "Tech Building" ],
      [ "Main Library", "Main Library" ],
      [ "Deering Library", "Deering Library" ],
      [ "Mudd Library", "Mudd Library" ],
      [ "Ford", "Ford" ]
    ]
  end

  # Formats duration from minutes into hours and minutes or just minutes
  def format_duration(minutes)
    return nil if minutes.nil? || minutes.zero?

    hours = minutes / 60
    remaining_minutes = minutes % 60

    if hours > 0 && remaining_minutes > 0
      "#{hours} #{hours == 1 ? 'hour' : 'hours'}, #{remaining_minutes} #{remaining_minutes == 1 ? 'minute' : 'minutes'}"
    elsif hours > 0
      "#{hours} #{hours == 1 ? 'hour' : 'hours'}"
    else
      "#{remaining_minutes} #{remaining_minutes == 1 ? 'minute' : 'minutes'}"
    end
  end
end
