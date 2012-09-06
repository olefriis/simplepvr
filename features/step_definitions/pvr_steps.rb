def find_or_create_channel_with_name(name)
  channel = SimplePvr::Model::Channel.get(:name => name)
  channel || SimplePvr::Model::Channel.add(name, 0, 0)
end

Given /the following programmes\:/ do |programme_table|
  programme_table.hashes.each do |programme|
    channel = find_or_create_channel_with_name(programme['channel'] || 'Channel 1')
    SimplePvr::Model::Programme.add(channel, programme['title'] || '', programme['subtitle'] || '',
      programme['description'] || '', Time.now, 60.minutes)
  end
end

Given /the following channels\:/ do |channel_table|
  channel_table.hashes.each do |channel|
    SimplePvr::Model::Channel.add(channel['name'], 0, 0)
  end
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