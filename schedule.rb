require File.dirname(__FILE__) + '/lib/simplepvr'

schedule do
  record 'DR K', 'Borgias', 'Jul 10 2012 20:46:00', 60.minutes
  record 'TV 2 | Danmark', 'Sports news', 'Jul 11 2012 12:15:00', 20.minutes
end
