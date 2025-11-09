class AddAvatarColorToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :avatar_color, :string
  end
end
