require File.dirname(__FILE__) + '/lib/simplepvr'

schedule do
  record 'Borgias', from:'DR K', at:'Jul 10 2012 20:46:00', for:60.minutes
  record 'Sports news', from:'TV 2 | Danmark', at:'Jul 11 2012 12:15:00', for:20.minutes
end
