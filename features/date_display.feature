Feature: Display dates with day of the week
  As a user of GatherEd
  I want to see dates displayed with the day of the week in study group listings
  So that I can better understand when study groups are scheduled

  Background:
    Given I am logged in as a student

  Scenario: Study group dates include day of week in course view
    When I visit the course page for "STAT 350 – Regression" at "/courses/7"
    Then I should see a study group called "Midterm prep"
    And I should see "Tuesday, Dec 09, 2025 at 02:00 PM - 04:00 PM" as the study group date