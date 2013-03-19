Feature: Week overview
  In order to find out what's on a specific channel
  As a user
  I want the weekly schedules for a channel

Background:
  Given the following channels:
    | name      |
    | Channel 1 |
    | Channel 2 |
  And the following programmes:
    | title              | subtitle                        | channel   | day |
    | Bonderøven         | Danish documentary              | Channel 1 |   1 |
    | Blood and Bone     | American action movie from 2009 | Channel 1 |   2 |
    | The future is here | American action movie from 2032 | Channel 1 |   8 |
    | The past is here   | American action movie from 1992 | Channel 1 |  -1 |
    | Noddy              | Children's programme            | Channel 2 |   3 |
  And I have navigated to the week overview for channel "Channel 1"

Scenario: I see programmes for the following week on the channel
  Then I should see "Bonderøven"
  And I should see "Blood and Bone"
  But I should not see "The future is here"
  And I should not see "Noddy"

Scenario: I can go to the next week
  When I follow ">>"
  Then I should see "The future is here"
  But I should not see "Bonderøven"

Scenario: I can go to the previous week
  When I follow "<<"
  Then I should see "The past is here"
  But I should not see "Bonderøven"

Scenario: I can go to the programme description
  Given I follow "Bonderøven"
  Then I should see "Danish documentary"
  And I should see "Episode 23/40"
