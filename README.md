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

So I wanted to create a really simple PVR, making it possible for others to hack away and have fun while
recording TV shows for the rest of the family.

It's based on the HDHomeRun command-line utility, which means it's:

* built on something that's officially supported by SiliconDust (the makers of HDHomeRun).
* really simple.
* limited to supporting HDHomeRun tuners.

There are back-end implementations in both Ruby and Python. Please look in the respective folders to see
how to install and operate the two versions.

XBMC Plug-In
============
There's a very simple XBMC plug-in, which resides in the `plugins/xbmc` folder. Generate a ZIP file
containing the plug-in and install it through XBMC's settings page (the ZIP file will be placed in
the "output" folder) by running this in the plugins/xbmc folder:

        rake package

After installing the plug-in, remember to look through the plug-in's settings page in XBMC.
Here, you set up the server URL and username / password, in case you have secured your server as
described above.

The plug-in allows you to browse your recordings, watch them, and delete them. To delete, press
the "C" key, or right-click your mouse on a show or a recording. Then you can choose "Delete" from
the context menu.

To get information on a given recording, press the "I" key when a recording is selected.

Please note: XBMC currently has to run on the same machine as the SimplePVR backend. This may change
in the future, but currently the backend is not fast enough at streaming files through HTTP.
