FactoryBot.define do
  factory :student do
    sequence(:name) { |n| "Test Student #{n}" }
    sequence(:email) { |n| "student#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    avatar_color { "#9333ea" }
  end

  factory :user, parent: :student
end
