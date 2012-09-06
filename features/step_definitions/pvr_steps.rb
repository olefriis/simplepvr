Given /the following programmes\:/ do |programme_table|
  channel = SimplePvr::Model::Channel.add('Channel 1', 0, 0)

  programme_table.hashes.each do |programme|
    SimplePvr::Model::Programme.add(channel, programme['title'] || '', programme['subtitle'] || '',
      programme['description'] || '', Time.now, 60.minutes)
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