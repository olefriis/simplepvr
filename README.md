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

It might not always be completely straightforward... we use DataMapper, which in turn relies on bcrypt-ruby,
which compiles some native stuff. So on MacOS, you need to install XCode and its command-line utilities, or
get "make" in some other way. On Linux, it should just work. Don't know about Windows.

Also, Nokogori might be problematic on some platforms, but importing XMLTV is three times faster with
Nokogiri than with the built-in REXML (counting the whole process of importing XMLTV, not just reading the
XML).

How to use from command line
============================
Edit schedule.rb. It will look like this:

        require File.dirname(__FILE__) + '/lib/simplepvr'
		
		schedule do
		  record 'Borgias', from:'DR K', at:Time.local(2012, 7, 10, 20, 46), for:60.minutes
		  record 'Sports news', from:'TV 2 | Danmark', at:Time.local(2012, 7, 11, 12, 15), for:20.minutes
		end

which will record two shows of 60 and 20 minutes' duration on the channels 'DR K' and 'TV 2', respectively. After
specifying your shows, start up the system:

        bundle exec ruby schedule.rb

The system will wait for the specified start times, and will then start the recordings. First time you start up
the system, it will do a channel scan. This is not needed later.

The above example is very straight-forward, but since it's just Ruby, you can program your own schedules for e.g.
recording every Thursday on a specific channel, or recording the news from the same timeslot every evening.

How to start the (simple!) web server
=====================================
For this to make any sense at all, you need to use XMLTV (read below). Start the server by running

        bundle exec ruby pvr_server.rb

...and go to [http://localhost:4567](http://localhost:4567).

XMLTV
=====
If you have an XMLTV file, you're in luck: You can read that into the system and set up schedules like this:

        schedule do
          record 'Borgias', from:'DR K'
		end

...and all shows withe the name 'Borgias' from 'DR K' will be found and scheduled. The recording will start 2
minutes before the scheduled programme and end 5 minutes later, just in case the programme doesn't start at the
exact planned time. If you don't care about which channel the show is on, you can just specify the show title:

        schedule do
          record 'Borgias'
        end

To use this feature, first you must specify in a YAML file how the channel IDs in your xmltv file relates to the
channel names that the HDHomeRun has found for you. Create a file called e.g. "channel_mappings.yaml":

        www.ontv.dk/tv/1: DR 1
		www.ontv.dk/tv/2: DR 2

Then read your XMLTV file and the mappings file:

        bundle exec ruby read_xmltv.rb programmes.xmltv channel_mappings.yaml

...and wait a little. Then start up the system as normal, and you're done.

If you're running the web server, you can tell it to update its schedules without restarting the server. This is
done by POST'ing to /schedules/reload on the server, e.g.:

        curl -d "" localhost:4567/schedules/reload

Recordings
==========
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
* metadata.yml: Recording time, title, channel, etc.

Future?
=======
* Extend the web interface a bit.
* "Gemify" the stuff, so installation becomes a breeze.
* Make an API (REST interface?), so that everything can be manipulated by e.g. a fancy web GUI or a desktop GUI,
  in case somebody would like to write one.
* Utilize more than one tuner in the HDHomeRun box.
* Speed up XMLTV import.
* Saving with the hdhomerun_config command is done through a shell script, so we can shut it down properly. I'd
  like a simpler solution, but haven't found anything that works both on OS X and Linux.

...all while cleaning up the code, making it more readable. I surely will accept pull requests!

But then...
-----------
Well, I don't know... I'm not sure we should take this much further. Let this be a nice, hackable library,
not too big for people to read and understand.

I'd love to make a really fancy web GUI on top of this library, giving a desktop-like feeling in the browser (and
putting that HTML5 video tag to good use), but that should really happen as a separate project. You are free to
beat me to this!

Development
===========
Run the specs like this:

        bundle exec rspec

There's a semi-manual test of the actual recording, since I'm not sure how to check automatically that
we can record a stream from a HDHomeRun box. Run it with

        bundle exec ruby spec/schedule_test.rb

After running this, a new recording should be present in "recordings/test/(sequence number)/stream.ts",
with 5 seconds of recording from the channel specified in the test (you need to alter the test file to
your available channels).