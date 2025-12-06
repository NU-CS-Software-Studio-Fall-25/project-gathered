Feature: Site Footer
  As a user of GatherEd
  I want to see a footer on every page
  So that I can access important links and navigation

  Background:
    Given I am on the GatherEd application

  Scenario: Footer appears on the dashboard page
    When I visit the dashboard page
    Then I should see a footer
    And the footer should contain "Dashboard"
    And the footer should contain "Search"
    And the footer should contain "My Groups"
    And the footer should contain "Calendar"
    And the footer should contain "Map"

  Scenario: Footer displays GatherEd branding and copyright
    When I visit any page
    Then I should see the GatherEd logo in the footer
    And the footer should contain copyright information
    And the footer should display the current year

  Scenario: Footer navigation links are functional
    When I visit the dashboard page
    And I click on "Search" in the footer
    Then I should be redirected to the search page

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
