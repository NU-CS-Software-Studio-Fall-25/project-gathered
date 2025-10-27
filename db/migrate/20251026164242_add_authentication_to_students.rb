class AddAuthenticationToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :email, :string, null: false
    add_column :students, :password_digest, :string, null: false
    add_index :students, :email, unique: true
  end
end
