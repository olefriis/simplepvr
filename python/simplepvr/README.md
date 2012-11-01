What?
=====
This is a Python implementation of the backend used by simplepvr.

The motivation for reimplementing the backend in Python is that I have a Synology DS209 NAS.
The NAS use the ARM cpu architecture and it comes with busybox linux installed, Python is installed
as well. No Ruby though.

Since the HDHomerun library can fairly easily be compiled for running on the ARM cpu architecture
I decided to implement a Python version of the backend. That way simplepvr can run entirely on my NAS, and
I don't need a PC/laptop running for me to be able to schedule recordings.

The feature set of the Python backend will be the same as that of the Ruby frontend.

Since the APIs will be identical, the frontend should be indifferent whether or not it is running against the
Ruby- or Python backend.

Install
=======
To install the required libraries for the Python backend - do:
    pip install -r requirements.txt

Install on a Synology NAS
=========================
This guide requires the NAS to be 'bootstrapped', see
    http://forum.synology.com/wiki/index.php/Overview_on_modifying_the_Synology_Server,_bootstrap,_ipkg_etc#How_to_install_ipkg

    After the Synology has been bootstrapped, you need to install the required libraries for the Python backend:

    ipkg update                                 # Update the list of packages that can be installed
    ipkg upgrade                                # Upgrade the packages that are outdated on your system

    ipkg install git                            # Install git on your NAS (so the simplepvr repo can be cloned later on)

    # In my experience the SimplePVR is much faster on Python 2.7 than 2.6 - so I install 2.7 on my bootstrapped NAS:
    ipkg install python27	                    # Install Python 2.7 if it is not on your system
    ipkg install py27-setuptools                # Installs setuptools
    curl https://raw.github.com/pypa/pip/master/contrib/get-pip.py | python2.7   # Install pip


    # Clone the SimplePVR repo:
    git clone git://github.com/olefriis/simplepvr.git /volume1/@appstore/simplepvr

    # Install the SimplePVR Python dependencies
    pip-2.7 install -r /volume1/@appstore/simplepvr/python/simplepvr/requirements.txt

    # If pip install fails with an error like this:
    #    "/opt/local/lib/python2.5/site-packages (in --site-dirs) does not exist"
    #    (note the version in the site-packages path does not match the version of the pip command you are using)
    #
    #    This problem can be fixed by editing
    #    /opt/lib/python2.6/distutils/distutils.cfg and correct the path /opt/local/lib/python2.5/site-packages to point
    #    to the 2.6 site-packages instead.
    #
    # When distutils.cfg is fixed, rerun 'pip-2.6 install distutils' - which should now complete without problems.


    # Create directory for the configuration
    mkdir /volume1/@appstore/.simplepvr
    cp /volume1/@appstore/simplepvr/python/simplepvr/etc/simplepvr.ini.example /volume1/@appstore/.simplepvr/simplepvr.ini

    # Edit /volume1/@appstore/.simplepvr/simplepvr.ini and set a proper path for 'recordings_path' setting.
    # This setting controls where recorded programmes will be stored on your system.
    # The path should only be used for SimplePVR recordings. Either create a new share in the Synology Web interface,
    # or use a subfolder in an existing share.
    # Also verify that the folder for storing the log file exists, if not, create it or edit the 'file' setting so it
    # points to an existing folder
    #


    # Copy the startup script into place
    cp /volume1/@appstore/simplepvr/python/simplepvr/etc/S99simplepvr /opt/etc/init.d/S99simplepvr
    chmod u+x /opt/etc/init.d/S99simplepvr

    # NOTE: S99simplepvr defaults to python2.7 - if you have 2.6 you need to update the PYTHON_EXEC variable in
    # the script.

    # Start the daemon - this can take several minutes the first time as it will ask the HDHomerun to scan for channels.
    # If you already have the output from a previous scan you would like to use put a 'channels.txt' file in the
    # /volume1/@appstore/.simplepvr folder with the contents of the scan from earlier.
    /usr/local/etc/rc.d/S99simplepvr start

    # When the system is done scanning (or done parsing the channels.txt) - the Web gui can be accessed:
    http://<url_to_nas>:8000/

    # Next step is to add programme data to the system.
    # I use timefor.tv as xmltv provider, so I use a cronjob to download a new EPG once a day

    # Create dir for scripts
    mkdir /volume1/@appstore/scripts
    cp /volume1/@appstore/simplepvr/python/simplepvr/etc/fetch_xmltv.sh /volume1/@appstore/scripts
    chmod u+x /volume1/@appstore/scripts/fetch_xmltv.sh

    # Edit the script and fix the URL_XMLTV_DATA variable

    # Add an entry to /etc/crontab (there must be one TAB between the columns)
    38	3	*	*	1,3,5,6	root	/opt/bin/bash /volume1/@appstore/scripts/fetch_xmltv.sh &> /var/log/simplepvr/fetch_xmltv.log


    # Restart the cron deamon
    /usr/syno/etc/rc.d/S04crond.sh stop && /usr/syno/etc/rc.d/S04crond.sh start


    # In order to read programme data from an XMLTV file, we need to create a mapping between the HDHomerun channel name
    # and the XMLTV channel id - please see the "Usage" section of this readme for an explanation of how to do this.



Usage
=====

Channel mappings
----------------
Either create a channel mappings file by hand with the format:
    xmltv-id: HDHomerun-name

    The mapping for DR 1 look like this:
    www.ontv.dk/tv/1: DR 1

Or use the auto_mapper.py tool to automatically generate the channel mappings. The automapper will not be able to
guess all the channels. The channels it is unable to guess will have FIXME in the channel name.

To use the automapper do the following:
    $ cd util
    $ python automapper.py xmltv_epg.xml hdhr_scan.log
    $ cp channel_mappings.yaml ../

Manually edit- and fix the FIXME lines in channel_mappings.yaml.
E.g. the channel mapping entry for TV 2 Norge look like this after automapper has created the file:
    '[48] FIXME: XMLTV ID HERE': TV 2 Norge

To fix this mapping, find TV 2 Norge in the XMLTV epg file -
	    <channel id="www.ontv.dk/tv/142">
	        <display-name lang="no">TV2 NO</display-name>
					<icon src="http://ontv.dk/imgs/epg/logos/tv2no_big.gif" />
	    </channel>

    Replace the 'FIXME...' with the value of the id-attribute, so the mapping becomes:

    www.ontv.dk/tv/142: TV 2 Norge

Parse the XMLTV EPG into simple_pvr
-----------------------------------

    $ python read_xmltv.py xmltv_epg.xml channel_mappings.yaml


Start the web server
--------------------

To start the server
    python pvr_server.py

Next open your favourite browser and go to
    http://localhost:8000



Transcoding
===========
If you want to have a try at transcoding the recorded MPEG-TS, have a look at the etc/transcode_*.sh files. They are
built for iPad2+, and iPhone4+ - but should also work on most newer Android devices.

If running on the Synology - you need to fix the ptread library symlink:
    rm /opt/arm-none-linux-gnueabi/lib/libpthread.so.0
    ln -s /lib/libpthread.so.0 /opt/arm-none-linux-gnueabi/lib/
   (Fix found here: http://blog.thomas-lauria.de/archives/19-unison-auf-Synology-DS211.html)

   ipkg install yasm lame x264

The scripts require you to have ffmpeg installed - and that you have placed the ffmpeg presets in ~/.ffmpeg.
If you did not compile ffmpeg yourself, the ffmpeg presets can be acquired from Github from this project:
 https://github.com/joeyblake/FFmpeg-Presets

