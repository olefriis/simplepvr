require File.dirname(__FILE__) + '/lib/simple_pvr'

schedule do
  record 'Borgias', from:'TV4 Sverige'
  record 'Sports news', from:'TV 2 | Danmark', at:'Jul 11 2012 12:15:00', for:20.minutes
end
