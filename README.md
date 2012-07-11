What?
=====
A really, really simple PVR (Personal Video Recorder) system which only supports the HDHomeRun network
tuners.

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

Then you should do a channel scan on your HDHomeRun device:

        hdhomerun_config <device id> scan /tuner0 channels.txt

How to use
==========
Edit schedule.rb. It will look like this:

        require File.dirname(__FILE__) + '/lib/simplepvr'
		
		schedule do
		  record 'DR K', 'Borgias', 'Tue Jul 10 20:46:00 +0200 2012', 60.minutes
		  record 'TV 2', 'Sports news', 'Wed Jul 11 12:15:00 +0200 2012', 20.minutes
		end

which will record two shows of 60 and 20 minutes' duration on the channels 'DR K' and 'TV 2', respectively. After
specifying your shows, start up the system:

        bundle exec ruby schedule.rb

The system will wait until the specified start times, and will then start the recordings. The recordings are
placed in the "recordings/" folder, named after the show ("Borgias" and "Sports news" in the example above).
Inside this folder are two files:

* stream.ts: The actual stream. Let VLC or another media player show these for you.
* hdhomerun_save.log: The output from the actual recording command.

Future?
=======
First: Perform channel scan on first start.

...then: Parse XMLTV files, expose a simple web GUI for scheduling recordings. Utilize more than one tuner
in the HDHomeRun box.

...all while: Cleaning up the code, making it more readable. I surely will accept pull requests!

But then: Well, I don't know... I'm not sure we should take this much further. Let this be a nice,
hackable library, not too big for people to read and understand.

Development
===========
Run the specs like this:

        bundle exec rspec spec/*_spec.rb

There's a semi-manual test of the actual recording, since I'm not sure how to check automatically that
we can record a stream from a HDHomeRun box. Run it with

        bundle exec ruby spec/recorder_test.rb

After running this, a new recording should be present in "recordings/test/stream.ts", with 5 seconds of
recording from the channel specified in the test (you need to alter the test file to your tuner and
your available channels).