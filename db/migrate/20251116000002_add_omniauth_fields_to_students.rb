class AddOmniauthFieldsToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :provider, :string unless column_exists?(:students, :provider)
    add_column :students, :uid, :string unless column_exists?(:students, :uid)

    unless index_exists?(:students, [ :provider, :uid ])
      add_index :students, [ :provider, :uid ], unique: true
    end
  end
end
