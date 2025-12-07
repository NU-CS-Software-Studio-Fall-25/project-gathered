module SystemHelpers
  def sign_in(student)
    visit login_path
    fill_in 'Email', with: student.email
    fill_in 'Password', with: student.password
    click_button 'Sign In'
  end
end
