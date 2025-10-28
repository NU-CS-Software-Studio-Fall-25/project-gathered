class FixStudentsEmailForProduction < ActiveRecord::Migration[8.0]
  def up
    # First, add email column as nullable
    add_column :students, :email, :string, null: true unless column_exists?(:students, :email)
    
    # Update existing students with placeholder emails
    Student.where(email: nil).find_each do |student|
      student.update_column(:email, "student#{student.student_id}@example.com")
    end
    
    # Now make email column not null
    change_column_null :students, :email, false
    
    # Add password_digest column if it doesn't exist
    add_column :students, :password_digest, :string, null: false unless column_exists?(:students, :password_digest)
    
    # Update existing students with default password
    Student.where(password_digest: nil).find_each do |student|
      student.update_column(:password_digest, BCrypt::Password.create("password123"))
    end
    
    # Add unique index on email
    add_index :students, :email, unique: true unless index_exists?(:students, :email)
  end

  def down
    remove_index :students, :email if index_exists?(:students, :email)
    remove_column :students, :password_digest if column_exists?(:students, :password_digest)
    remove_column :students, :email if column_exists?(:students, :email)
  end
end