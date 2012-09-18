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

If you'd like thumbnails for the recorded shows, you need FFMPEG on the command-line. Install it using
MacPorts, Homebrew, or whatever.

Running the web GUI
===================
Start the server by running

        bundle exec ruby pvr_server.rb

...and go to [http://localhost:4567](http://localhost:4567). If you want to expose this URL to the outside
world, you'd better supply a username and password:

        username=me password=secret bundle exec ruby pvr_server.rb

This will secure the application with Basic HTTP Authentication.

XMLTV
=====
First you must specify in a YAML file how the channel IDs in your XMLTV file relates to the
channel names that the HDHomeRun has found for you. Create a file called e.g. "channel_mappings.yaml":

        www.ontv.dk/tv/1: DR 1
		www.ontv.dk/tv/2: DR 2

Then read your XMLTV file and the mappings file:

        bundle exec ruby read_xmltv.rb programmes.xmltv channel_mappings.yaml

...and wait a little. You can tell the webserver to update its schedules without restarting the server. This is
done by POST'ing to /api/schedules/reload on the server, e.g.:

        curl -d "" localhost:4567/api/schedules/reload

Or, if you've secured your web server with Basic HTTP Authentication, specify username and password:

        curl -d "" -u me:secret localhost:4567/api/schedules/reload

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
  * Playback of recordings (also on mobile devices).
  * Some better overview pages, e.g. "all children programmes", "all movies this week".
  * Possibility to set up schedules defined by a channel, a start time, and a duration (and a name,
    probably), so that the web GUI is usable even without XMLTV.
* Record specific programmes, not only "record all with this title".
* Exclude specific programmes from "all with this title".
* Duplication detection.
* Visualize conflicts in upcoming recordings.
* XMLTV import:
  * Let SimplePVR itself fetch XMLTV URLs at specified times of day.
  * Set-up of matching XMLTV IDs to channels could make good use of a GUI.
  * Parse and make use of channel icons, programme icons, episode numbers, etc.
* Searching for tuners and scanning for channels would be nice through a GUI.
* Saving with the hdhomerun_config command is done through a shell script, so we can shut it down properly. I'd
  like a simpler solution, but haven't found anything that works both on OS X and Linux.
  [Bluepill](https://github.com/arya/bluepill) seems to do the job, but seems like too big a hammer...

Some features would be cool to have, but I don't have a personal need for them, so they will only
happen if *you* implement them and send me a pull request.

* Some kind of live TV.
* Create metadata for XBMC and Serviio.

Development
===========
Run the specs like this:

        bundle exec rspec

Run the JavaScript tests by first calling

        test/scripts/test-server.sh

then opening a browser on the shown URL. Capture the browser in strict mode. After this, you can run

        test/scripts/test.sh

any number of times. However, the test-server needs to be restarted from time to time.

Run the integration tests like this:

        bundle exec cucumber
