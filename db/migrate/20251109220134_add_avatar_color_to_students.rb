class AddAvatarColorToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :avatar_color, :string, default: "#9333ea"
  end
end
