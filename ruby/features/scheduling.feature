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
  And I choose to record the programme on this channel
  And I am on the schedules page
  Then I should see the schedule "Bonderøven on Channel 1"
  And there should be 2 upcoming recordings

Scenario: Schedule by title for all channels
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I choose to record the programme on any channel
  And I am on the schedules page
  Then I should see the schedule "Bonderøven"
  But I should not see the schedule "Bonderøven on Channel 1"
  And there should be 3 upcoming recordings

Scenario: Schedule a specific programme
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I choose to record just this programme
  And I am on the schedules page
  Then I should see the timed schedule "Bonderøven on Channel 1"
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
  And I choose to record the programme on this channel
  And I wait 2 seconds
  When I am on the status page
  Then I should see "Recording 'News right now' on channel 'Channel 1'"

Scenario: Remove schedule
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I choose to record the programme on this channel
  And I am on the schedules page
  And I follow "Delete"
  Then I should not see the schedule "Bonderøven on Channel 1"
  And there should be 0 upcoming recordings

Scenario: Defining conflicting schedules
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I choose to record the programme on any channel
  And I have navigated to the programme page for "Noddy" on channel "Channel 1"
  And I choose to record the programme on this channel
  When I am on the schedules page
  Then there should be a conflict

Scenario: Fixing conflicts by removing a schedule
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I choose to record the programme on any channel
  And I have navigated to the programme page for "Noddy" on channel "Channel 1"
  And I choose to record the programme on this channel
  When I am on the schedules page
  And I follow "Delete"
  Then there should be no conflicts

Scenario: Removing a specific recording from a schedule
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I choose to record the programme on any channel
  And I am on the schedules page
  Then there should be 3 upcoming recordings
  When I follow "Do not record this specific show"
  Then there should be 2 upcoming recordings
  And I should see "Exception: Bonderøven"

Scenario: Editing a schedule
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I choose to record the programme on any channel
  And I am on the schedules page
  And I follow "Edit"
  And I fill in "Name of show" with "Noddy"
  And I press "Update"
  Then there should be 1 upcoming recording
  And I should not see "Bonderøven"

Scenario: Editing a schedule so that only some weekdays are allowed
  Given I have navigated to the programme page for "Bonderøven" on channel "Channel 1"
  And I choose to record the programme on any channel
  And I am on the schedules page
  And I follow "Edit"
  And I check "Filter by weekday"
  And I check "Record Mondays"
  And I check "Record Wednesdays"
  And I check "Record Sundays"
  And I press "Update"
  Then I should see "(Mondays, Wednesdays, and Sundays)"