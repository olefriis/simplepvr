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
    | title           | subtitle                        | channel   | day |
	| Blast from past | Prehistoric documentary         | Channel 1 |  -1 |
    | Bonderøven      | Danish documentary              | Channel 1 |   0 |
    | Blood and Bone  | American action movie from 2009 | Channel 1 |   0 |
    | Noddy           | Children's programme            | Channel 2 |   0 |

Scenario: Channel overview shows channel names
  Given I am on the channel overview page
  Then I should see "Channel 1"
  And I should see "Channel 2"
  And I should see "Animals"

Scenario: Channel overview shows upcoming programmes
  Given I am on the channel overview page
  Then I should see "Bonderøven"
  But I should not see "Blast from past"

Scenario: Clicking on an upcoming programme reveals more programme information
  Given I am on the channel overview page
  And I follow "Bonderøven"
  Then I should see "Danish documentary"

Scenario: Channel filtering
  Given I am on the channel overview page
  And I fill in "channel_filter" with "channel"
  Then I should see "Channel 1"
  And I should see "Channel 2"
  But I should not see "Animals"

Scenario: I can go to a week overview for a given channel
  Given I am on the channel overview page
  And I fill in "channel_filter" with "Channel 1"
  And I follow "..."
  Then I should see "Bonderøven"
  And I should see "Blood and Bone"
  But I should not see "Noddy"