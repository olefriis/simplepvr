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
in MythTV and suddenly went away. I really don't like using systems this brittle.

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

Running the web GUI
===================
For this to make any sense at all, you need to use XMLTV (read below). Start the server by running

        bundle exec ruby pvr_server.rb

...and go to [http://localhost:4567](http://localhost:4567). If you want to expose this URL to the outside
world, you'd better supply a username and password:

        username=me password=secret bundle exec ruby pvr_server.rb

This will secure the application with Basic HTTP Authentication.

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

Or, if you've secured your web server with Basic HTTP Authentication, specify username and password:

        curl -d "" -u me:secret localhost:4567/schedules/reload

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

Inside the numbered directories are these files:

* stream.ts: The actual stream. Let VLC or another media player show these for you.
* hdhomerun_save.log: The output from the actual recording command.
* metadata.yml: Recording time, title, channel, etc.

Future?
=======
This projects needs to be a nice, readable, hackable, tested system. No pull requests are
accepted that violate this.

There are lots of stuff I'd like to do, but I have no deadline - which means that pull requests
are the only means you have for speeding things up. This includes:

* "Gemify" the stuff, so installation becomes a breeze.
* Web interface:
  * Better overview of recordings.
  * Text search for programmes.
  * Playback of recordings (also on mobile devices).
  * Some better overview pages, e.g. "all children programmes", "all movies this week".
  * Possibility to set up schedules defined by a channel, a start time, and a duration (and a name,
    probably), so that the web GUI is usable even without XMLTV.
* Record specific programmes, not only "record all with this title".
* Exclude specific programmes from "all with this title".
* Duplication detection.
* Visualize conflicts in upcoming recordings.
* XMLTV import:
  * Needs more speed!
  * Let SimplePVR itself fetch XMLTV URLs at specified times of day.
  * Set-up of matching XMLTV IDs to channels could make good use of a GUI.
  * Parse and make use of channel icons, programme icons, episode numbers, etc.
* Searching for tuners and scanning for channels would be nice through a GUI.
* Saving with the hdhomerun_config command is done through a shell script, so we can shut it down properly. I'd
  like a simpler solution, but haven't found anything that works both on OS X and Linux.
* Remove "the schedule.rb way" to set up recordings, since nobody will probably use this...

Some features would be cool to have, but I don't have a personal need for them, so they will only
happen if *you* implement them and send me a pull request.

* Some kind of live TV.
* Create metadata for XBMC and Serviio.

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

Run the JavaScript tests by first calling

        test/scripts/test-server.sh

then opening a browser on the shown URL. Capture the browser in strict mode. After this, you can run

        test/scripts/test.sh

any number of times. However, the test-server needs to be restarted from time to time.