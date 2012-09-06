Feature: Channel overview
  In order to find what's on TV
  As a user
  I want a good channel overview

Background:
  Given the following channels:
    | name      |
    | Channel 1 |
    | Channel 2 |
    | Animals   |
  And the following programmes:
    | title          | subtitle                        | channel   | day |
    | Bonderøven     | Danish documentary              | Channel 1 |   1 |
    | Blood and Bone | American action movie from 2009 | Channel 1 |   2 |
    | Noddy          | Children's programme            | Channel 2 |   3 |

Scenario: Channel overview
  Given I am on the channel overview page
  Then I should see "Channel 1"
  And I should see "Channel 2"
  And I should see "Animals"

Scenario: Channel filtering
  Given I am on the channel overview page
  And I fill in "channel_filter" with "channel"
  Then I should see "Channel 1"
  And I should see "Channel 2"
  But I should not see "Animals"

Scenario: Weekly overview
  Given I am on the channel overview page
  And I fill in "channel_filter" with "Channel 1"
  And I follow "View programmes"
  Then I should see "Bonderøven"
  And I should see "Blood and Bone"
  But I should not see "Noddy"