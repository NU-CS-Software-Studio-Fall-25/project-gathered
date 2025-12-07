class AddHighContrastToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :high_contrast, :boolean, default: false, null: false
  end
end
