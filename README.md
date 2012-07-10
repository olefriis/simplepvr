What?
=====
A really, really simple PVR (Personal Video Recorder) system which only supports the HDHomeRun network
tuners.

Why?
====
MythTV stopped working for me in the 0.25 release. And even though MythTV has loads of merits, I just
have no idea what to do when it stops working - I have no control whatsoever.

So I wanted to create a really simple PVR in Ruby, making it possible for others to hack away and have
fun while recording TV shows for the rest of the family.

Installation?
=============
You need Ruby 1.9.2 (or newer - 1.9.0 or newer is probably enough). Dump this source somewhere, and run

        gem install bundler
        bundle install
        bundle exec ruby schedule.rb

Status?
=======
Right now, it's too simple for anybody but myself to use. You need to alter the schedule.rb file:

        require 'rufus/scheduler'
		require './recorder'

		scheduler = Rufus::Scheduler.start_new

		scheduler.at 'Tue Jul 10 20:46:00 +0200 2012' do
		  recorder = Recorder.new('borgias', '12106FA4', 282000000, 1098)
		  recorder.start!
		  sleep 5*60
		  recorder.stop!
		end

		scheduler.join
		
This will record a show with the name "borgias" at 20:46 July the 10th 2012, on the specifiec HDHomeRun
device, the given frequency, and with the given channel ID. Oh, and it records 60 minutes (the 5*60 part).

This is ugly... the short-term ambition is to end up with this:

        require 'simplepvr'
		
		schedule do
		  record 'DR K', 'Tue Jul 10 20:46:00 +0200 2012', 60.minutes
		  record 'TV 2', 'Wed Jul 11 12:15:00 +0200 2012', 20.minutes
		end
		
to record two shows of 60 and 20 minutes' duration on the channels 'DR K' and 'TV 2', respectively.

Future?
=======
First: Auto-detect tuners, perform channel scan, clean up the interface.

Then: Parse XMLTV files, expose a simple web GUI for scheduling recordings.

But then: Well, I don't know... I'm not sure we should take this much further. Let this be a nice,
hackable library, not too big for people to read and understand.