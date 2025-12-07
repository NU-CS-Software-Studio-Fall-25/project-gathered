# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    sequence(:name) { |n| "Test Student #{n}" }
    sequence(:email) { |n| "student#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    avatar_color { "#9333ea" }
  end

  factory :user, parent: :student
end
