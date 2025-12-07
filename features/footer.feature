Feature: Site Footer
  As a user of GatherEd
  I want to see a footer on every page
  So that I can access important links and navigation

  Background:
    Given I am on the GatherEd application

  Scenario: Footer appears on the dashboard page
    When I visit the dashboard page
    Then I should see a footer

  Scenario: Footer displays GatherEd branding and copyright
    When I visit the dashboard page
    Then the footer should contain "GatherEd"
    And the footer should contain "Created by"
    And the footer should display the current year

  Scenario: Footer lists the creators
    When I visit the dashboard page
    Then the footer should list the creators:
      | Alex Anca |
      | Daniel Wong |
      | Ellis Mandel |
      | Matthew Song |

  Scenario: Footer appears consistently across all pages
    When I visit the dashboard page
    Then I should see a footer
    When I visit the search page
    Then I should see a footer
    When I visit the my groups page
    Then I should see a footer
    When I visit the calendar page
    Then I should see a footer
    When I visit the map page
    Then I should see a footer
    And the footer should contain "Created by"
