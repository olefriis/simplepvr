Feature: Scheduling
  In order to record programmes
  As a user
  I want to set up recording schedules

Background:
  Given the following programmes:
    | title          | subtitle             | channel   | day |
    | News right now | Just the news...     | Channel 1 |   0 |
    | Bonderøven     | Danish documentary   | Channel 1 |   1 |
    | Bonderøven     | Danish documentary   | Channel 2 |   1 |
    | Bonderøven     | Danish documentary   | Channel 1 |   3 |
    | Noddy          | Children's programme | Channel 1 |   1 |

Scenario: Nothing is scheduled by default
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

Scenario: Schedule a specific programme
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I press "Record just this programme"
  And I am on the schedules page
  But I should see the timed schedule "Bonderøven on Channel 1"
  And there should be 1 upcoming recordings


Scenario: Set up schedule manually
  Given I am on the schedules page
  And I fill in "Name" with "Bonderøven"
  And I select "Channel 1" from "Channel"
  And I press "Create schedule"
  Then I should see the schedule "Bonderøven on Channel 1"
  And there should be 2 upcoming recordings

Scenario: Scheduling the current programme starts recording immediately
  Given I am on the status page
  Then I should see "Idle"
  When I have navigated to the programme page for "News right now" on channel "Channel 1"
  And I press "Record on this channel"
  And I wait 2 seconds
  When I am on the status page
  Then I should see "Recording 'News right now' on channel 'Channel 1'"

Scenario: Remove schedule
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I press "Record on this channel"
  And I am on the schedules page
  And I follow "Delete"
  Then I should not see the schedule "Bonderøven on Channel 1"
  And there should be 0 upcoming recordings
