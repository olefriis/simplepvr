Feature: Programme search
  In order to find interesting programmes
  As a user
  I want to search through all programmes

Background:
  Given I am on the schedules page

Scenario: Autocomplete in programme search
  Given I enter "Bon" in the programme search field
  Then I should see the programme title suggestion "Bonderøven"

Scenario: Searching for a text reveals summary of programmes with matching titles
  Given I search for programmes with title "Bon"
  Then I should see "føllet Manfred er til hingstekåring" in the page contents