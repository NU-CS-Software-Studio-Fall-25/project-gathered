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

  # Renders a student's avatar - image if attached, otherwise color circle with initial
  # @param student [Student] the student object
  # @param size [String] Tailwind size classes (e.g., "w-8 h-8" or "w-16 h-16")
  # @param text_size [String] Tailwind text size class (e.g., "text-sm" or "text-2xl")
  # @param extra_classes [String] Additional CSS classes to apply
  def student_avatar(student, size: "w-8 h-8", text_size: "text-sm", extra_classes: "")
    return content_tag(:div, "", class: "#{size} rounded-full bg-slate-500") unless student

    if student.avatar.attached?
      image_tag(
        url_for(student.avatar),
        alt: "#{student.name}'s avatar",
        class: "#{size} rounded-full object-cover #{extra_classes}".strip
      )
    else
      color = student.avatar_color || "#9333ea"
      initial = (student.name.presence || "?")[0].upcase

      content_tag(
        :div,
        initial,
        class: "flex-shrink-0 #{size} rounded-full flex items-center justify-center text-white font-semibold #{text_size} #{extra_classes}".strip,
        style: "background-color: #{color};"
      )
    end
  end
end
