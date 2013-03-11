What?
=====
A really, really simple PVR (Personal Video Recorder) system which only supports the
[HDHomeRun network tuners](http://www.silicondust.com/). It's written in Ruby and is highly hackable. If
you don't want to hack it, but just want a solid PVR system, no worries: It's dead-simple to use.

SimplePVR does not contain its own player, but currently provides an XBMC plug-in and some half-hearted
browser playback. Apart from that, all recordings are stored in a simple directory structure (see below
for an explanation), so that you can just point your favorite player to the recordings.

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

You need Ruby 1.9.2 or newer (1.9.0 or newer is probably enough).

        gem install simple_pvr

It might not always be completely straightforward... simple_pvr uses DataMapper, which in turn relies on
bcrypt-ruby, which compiles some native stuff. So on MacOS, you need to install XCode and its command-line
utilities, or get "make" in some other way. On Linux, it should just work. Don't know about Windows.

If you'd like thumbnails for the recorded shows and ability to transcode recordings to WebM (so you can view
them directly in your browser), you need FFMPEG on the command-line. Install it using MacPorts, Homebrew,
"apt-get", or whatever.

Starting the server
===================
Run

        pvr_server

...and go to [http://localhost:4567](http://localhost:4567). If you want to expose this URL to the outside
world, you'd better supply a username and password:

        username=me password=secret pvr_server

This will secure the application with Basic HTTP Authentication.

XMLTV
=====
First you must specify in a YAML file how the channel IDs in your XMLTV file relates to the channel names
that the HDHomeRun has found for you. Create a file called e.g. "channel_mappings.yaml", with lines like this:

        www.ontv.dk/tv/1: DR 1
		www.ontv.dk/tv/2: DR 2

Then read your XMLTV file and the mappings file:

        pvr_xmltv programmes.xmltv channel_mappings.yaml

...and wait a little. You can tell the webserver to update its schedules without restarting the server. This is
done by POST'ing to /api/schedules/reload on the server, e.g.:

        curl -d "" localhost:4567/api/schedules/reload

Or, if you've secured your web server with Basic HTTP Authentication like I told you to, specify username and password:

        curl -d "" -u me:secret localhost:4567/api/schedules/reload

Recordings
==========
The recordings are laid out like this, from the directory where you ran pvr_server:

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

...and a few other files (thumbnails, transcoded version of the recording, etc.).

XBMC Plug-In
============
There's a very simple XBMC plug-in for SimplePVR. See [the home page](https://github.com/olefriis/simplepvr)
for more information.

Future?
=======
This projects needs to be a nice, readable, hackable, tested system. No pull requests are
accepted that violate this.

For version 1 of SimplePVR, I'd like to finish the following:

* "Gemify" the stuff, so installation becomes a breeze.
* More schedule editing, e.g.:
  * "Start early" and "end late" (currently 2 and 5 minutes).
  * Which time of day the schedule should be active (e.g. only the afternoon, ignoring all the
    re-runs earlier in the day).
* Removal of outdated schedules (the "Record single programme" and "Don't record this specific
  programme").

There is lots of stuff I'd like to do after that, but I have no deadline - which means that pull
requests are the only means you have for speeding things up. This includes:

* Web interface:
  * "Dashboard" giving "the big picture" of the status of the system (next 5 upcoming recordings,
    last 5 recorded programmes, current status, last couple of errors, whether there are any
    upcoming conflicts, etc.).
  * Better overview of recordings (a flat view).
  * Better overview pages, e.g. "all children programmes", "all movies this week", "tonight's
    programmes", ...
* Setting up schedules defined by a channel, a start time, and a duration (and a name,
  probably), so that the web GUI is usable even without XMLTV.
* Schedule editing: Show which programmes match the edited schedule, to make it easier to create
  a schedule which exactly matches your needs.
* XMLTV import:
  * Let SimplePVR itself fetch XMLTV URLs at specified times of day.
  * Set-up of matching XMLTV IDs to channels could make good use of a GUI.
  * Parse and make use of programme icons etc.
* Searching for tuners and scanning for channels would be nice through a GUI.
* Saving with the hdhomerun_config command is done through a shell script, so we can shut it down properly. I'd
  like a simpler solution, but haven't found anything that works both on OS X and Linux.
  [Bluepill](https://github.com/arya/bluepill) seems to do the job, but seems like too big a hammer...

Some features would be cool to have, but I don't have a personal need for them, so they will only
happen if *you* implement them and send me a pull request. Besides, some of them I have no clue how
to implement...

* Some kind of live TV.
* Create metadata for XBMC and Serviio.
* Duplication detection.
* Commercial detection.
* Record multiple programmes on same multiplex, so we are not restricted to only recording two
  programmes at once.

Development
===========
Run the specs and features like this:

        rake test

Run the JavaScript tests by first calling

        test/scripts/test-server.sh

then opening a browser on the shown URL. Capture the browser in strict mode. After this, you can run

        test/scripts/test.sh

any number of times. However, the test-server needs to be restarted from time to time.