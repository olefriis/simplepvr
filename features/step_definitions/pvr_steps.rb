def find_or_create_channel_with_name(name)
  channel = SimplePvr::Model::Channel.first(name: name)
  channel ? channel : SimplePvr::Model::Channel.add(name, 0, 0)
end

Given /the following programmes\:/ do |programme_table|
  programme_table.hashes.each do |programme|
    channel = find_or_create_channel_with_name(programme['channel'] || 'Channel 1')
    air_time = Time.now.advance(days: (programme['day'] || '0').to_i)
    SimplePvr::Model::Programme.add(channel, programme['title'] || '', programme['subtitle'] || '',
      programme['description'] || '', air_time, 60.minutes)
  end
end

Given /the following channels\:/ do |channel_table|
  channel_table.hashes.each do |channel|
    find_or_create_channel_with_name(channel['name'])
  end
end

Given /I have navigated to the week overview for channel "(.*)"/ do |channel|
  visit path_to('the channel overview page')
  fill_in('channel_filter', :with => channel)
  click_link('View programmes')
end

Given /I have navigated to the programme page for "(.*)" on channel "(.*)"/ do |title, channel|
  visit path_to('the channel overview page')
  fill_in('channel_filter', :with => channel)
  click_link('View programmes')
  click_link(title)
end

When /I enter "(.*)" in the programme search field/ do |query|
  fill_in('programme-search-query', :with => query)
end

When /I search for programmes with title "(.*)"/ do |query|
  fill_in('programme-search-query', :with => query)
  click_button('Search')
end

Then /I should see the programme title suggestion "(.*)"/ do |suggestion|
  page.should have_content(suggestion)
end

Then /I should see "(.*)" in the page contents/ do |text|
  within('#contents') do
    page.should have_content(text)
  end
end

Then /I should see the schedule "(.*)"/ do |text|
  within('#schedules') do
    page.should have_content(text)
  end
end

Then /I should see the timed schedule "(.*)"/ do |text|
  within('#schedules') do
    page.text.should =~ /#{text} .* \d+, \d{4} at \d?\d:\d\d/
  end
end

Then /I should not see the schedule "(.*)"/ do |text|
  within('#schedules') do
    page.should_not have_content(text)
  end
end

Then /there should be (\d*) upcoming recordings/ do |upcoming_recordings|
  find('#upcoming_recordings').all('h2').length.should == upcoming_recordings.to_i
end

Then /I wait (\d*) seconds/ do |seconds|
  sleep seconds.to_i
end