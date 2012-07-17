What?
=====
A really, really simple PVR (Personal Video Recorder) system which only supports the
[HDHomeRun network tuners](http://www.silicondust.com/). It's written in Ruby and is highly hackable. If
you don't want to hack it, but just want a solid PVR system, no worries: It's dead-simple to use.

Why?
====
MythTV stopped working for me and my HDHomeRun box in the 0.25 release. And even though MythTV has loads
of merits, I just have no idea what to do when it stops working - I am not in control of my media center.

During the last couple of years, I have spent a substantial amount of time on bugs that suddenly appeared
in MythTV and suddenly went away. I really don't like using systems which break like this.

So I wanted to create a really simple PVR in Ruby, making it possible for others to hack away and have
fun while recording TV shows for the rest of the family.

It's based on the HDHomeRun command-line utility, which means it's:

* built on something that's officially supported by SiliconDust (the makers of HDHomeRun).
* really simple.
* limited to supporting HDHomeRun tuners.

Installation
============
First of all, you need a computer and an HDHomeRun tuner box. On your computer, you need to have the
"hdhomerun_config" tool on the path.

You need Ruby 1.9.2 (or newer - 1.9.0 or newer is probably enough). Dump this source somewhere, and run

        gem install bundler
        bundle install

How to use
==========
Edit schedule.rb. It will look like this:

        require File.dirname(__FILE__) + '/lib/simplepvr'
		
		schedule do
		  record 'Borgias', from:'DR K', at:'Jul 10 2012 20:46:00', for:60.minutes
		  record 'Sports news', from:'TV 2 | Danmark', at:'Jul 11 2012 12:15:00', for:20.minutes
		end

which will record two shows of 60 and 20 minutes' duration on the channels 'DR K' and 'TV 2', respectively. After
specifying your shows, start up the system:

        bundle exec ruby schedule.rb

The system will wait for the specified start times, and will then start the recordings. First time you start up
the system, it will do a channel scan and put the results in channels.txt. This is not needed later, but if your
TV provider moves the channels around, you can force a channel scan by deleting channels.txt and restarting the
system.

The recordings are laid out like this:

* recordings/
  * Borgias/
     * 1/
     * 2/
  * Sports news/
     * 1/
     * 2/
     * 3/
  * ...

Inside the numbered directories are two files:

* stream.ts: The actual stream. Let VLC or another media player show these for you.
* hdhomerun_save.log: The output from the actual recording command.

Future?
=======
Small things first
------------------
* Richer API for setting schedules, e.g. being able to record a specific show every Thursday at 9 o'clock.

Then...
-------
* "Gemify" the stuff, so installation becomes a breeze.
* Make an API (REST interface?) to alter the schedule, so that the schedules can be manipulated by e.g. a
  fancy web GUI which can handle XMLTV etc.
* Utilize more than one tuner in the HDHomeRun box.
* Read XMLTV files and do some nice recording stuff with that.

...all while cleaning up the code, making it more readable. I surely will accept pull requests!

But then...
-----------
Well, I don't know... I'm not sure we should take this much further. Let this be a nice, hackable library,
not too big for people to read and understand.

I'd love to make a web GUI on top of this library (it must be possible to do some fancy HTML5 stuff for
showing TV schedules, setting up recordings, and watching recordings), but that should really happen as
a separate project. You are free to beat me to this!

Development
===========
Run the specs like this:

        rspec

There's a semi-manual test of the actual recording, since I'm not sure how to check automatically that
we can record a stream from a HDHomeRun box. Run it with

        ruby spec/simple_pvr/recorder_test.rb

After running this, a new recording should be present in "recordings/test/(sequence number)/stream.ts",
with 5 seconds of recording from the channel specified in the test (you need to alter the test file to
your tuner and your available channels).