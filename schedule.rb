require File.dirname(__FILE__) + '/lib/simplepvr'

schedule do
  record 'DR K', 'Borgias', 'Tue Jul 10 20:46:00 +0200 2012', 60.minutes
  record 'TV 2 | Danmark', 'Sports news', 'Wed Jul 11 12:15:00 +0200 2012', 20.minutes
end
