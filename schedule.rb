require File.dirname(__FILE__) + '/lib/simple_pvr'

schedule do
  record 'Borgias', from:'TV4 Sverige'
  record 'Sports news', from:'TV 2 | Danmark', at:Time.local(2012, 7, 11, 12, 15), for:20.minutes
end
