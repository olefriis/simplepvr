Feature: Scheduling
  In order to record programmes
  As a user
  I want to set up recording schedules

Background:
  Given the following programmes:
    | title              | subtitle             | channel   | day |
    | Bonderøven         | Danish documentary   | Channel 1 |   1 |
    | Bonderøven         | Danish documentary   | Channel 2 |   1 |
    | Bonderøven         | Danish documentary   | Channel 1 |   3 |
    | Noddy              | Children's programme | Channel 1 |   1 |

Scenario: Nothing is scheduled by defult
  Given I am on the schedules page
  Then there should be 0 upcoming recordings

Scenario: Schedule by title for a single channel
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I press "Record on this channel"
  And I am on the schedules page
  Then I should see the schedule "Bonderøven on Channel 1"
  And there should be 2 upcoming recordings

Scenario: Schedule by title for all channels
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I press "Record on any channel"
  And I am on the schedules page
  Then I should see the schedule "Bonderøven"
  But I should not see the schedule "Bonderøven on Channel 1"
  And there should be 3 upcoming recordings