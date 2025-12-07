# frozen_string_literal: true

require "cucumber/rails"

if Rails.env.test?
  ENV["DATABASE_URL"] ||= "postgresql://postgres:secret@db:5432/study_group_finder_test"
  DatabaseCleaner.allow_remote_database_url = true if DatabaseCleaner.respond_to?(:allow_remote_database_url)
end

ActionController::Base.allow_rescue = false

begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "Add database_cleaner-active_record to the Gemfile in the :test group to use it."
end

Cucumber::Rails::Database.javascript_strategy = :truncation
