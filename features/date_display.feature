Feature: Display dates with day of the week
  As a user of GatherEd
  I want to see dates displayed with the day of the week in study group listings
  So that I can better understand when study groups are scheduled

  Background:
    Given I am logged in as a student
    And there is a course "COMP_SCI 110" with code "COMP_SCI_110"

  Scenario: Study group dates include day of week in search results
    Given there is a study group for "COMP_SCI 110" on "2025-12-15" at "8:10" with topic "Lecture Group Review"
    When I go to the search page
    And I select the course "COMP_SCI 110"
    Then I should see "Monday, Dec 15, 2025" as part of the study group date