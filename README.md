What?
=====
A really, really simple PVR (Personal Video Recorder) system which only supports the
[HDHomeRun network tuners](http://www.silicondust.com/). It's written by programmers, for programmers. If
you don't want to hack it, but just want a solid PVR system, no worries: It's dead-simple to use.

SimplePVR does not contain its own player, but currently provides an XBMC plug-in and some half-hearted
browser playback. Apart from that, all recordings are stored in a simple directory structure, so that you
can just point your favorite player to the recordings.

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

Setup
=====
I started doing a back-end in Ruby, but Flemming, a friend and former colleague, thought it would be nice to
do a Python implementation. So we're embracing several back-end implementations. Choose the one you like:

* Ruby back-end: [https://github.com/olefriis/simplepvr-backend-ruby](https://github.com/olefriis/simplepvr-backend-ruby)
* Python back-end: [https://github.com/olefriis/simplepvr/tree/master/python](https://github.com/olefriis/simplepvr/tree/master/python)

Please look in the respective repositories to see how to install and operate them.

There is currently only one front-end-implementation:

* XBMC plug-in: [https://github.com/olefriis/simplepvr-frontend-xbmc](https://github.com/olefriis/simplepvr-frontend-xbmc)

You can use any player that can play plain files, such as VLC, MythTV, Plex, even XBMC without the plug-in.
The plug-in just gives a better experience. If you want to write a plug-in for another player, please don't
hesitate, and please let us know!!