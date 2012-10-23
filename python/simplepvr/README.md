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
    http://localhost:5000