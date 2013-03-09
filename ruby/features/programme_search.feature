Feature: Programme search
  In order to find interesting programmes
  As a user
  I want to search through all programmes

Background:
  Given the following programmes:
    | title          | subtitle                        |
    | Bonderøven     | Danish documentary              |
    | Blood and Bone | American action movie from 2009 |
    | Noddy          | Children's programme            |
  And I am on the schedules page

Scenario: Autocomplete in programme search
  Given I enter "Bon" in the programme search field
  Then I should see the programme title suggestion "Bonderøven"

Scenario: Searching for a text reveals summary of programmes with matching titles
  Given I search for programmes with title "Bon"
  Then I should see "Danish documentary" in the page contents