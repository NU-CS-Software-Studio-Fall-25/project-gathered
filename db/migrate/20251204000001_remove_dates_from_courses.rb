class RemoveDatesFromCourses < ActiveRecord::Migration[8.0]
  def change
    remove_column :courses, :start_date, :datetime
    remove_column :courses, :end_date, :datetime
  end
end
