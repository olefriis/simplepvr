import codecs, sys
from datetime import datetime
import xml.etree.ElementTree as xml
from dateutil.parser import parse
import time
from blessings import Terminal

t = Terminal()

from .master_import import Channel, Programme, safe_value
from .pvr_logger import logger

def timestamp(date):
    return time.mktime(date.timetuple())

def diff_seconds(date_from, date_to):
    return timestamp(date_to) - timestamp(date_from)

width = 60
def update_progress(progress):
    hashes = progress * width /100
    spaces = width-hashes
    with t.location(0, t.height - 1):
        sys.stdout.write('[{0}{1}] {2}%'.format('#'* hashes, ' '* spaces, progress))
        sys.stdout.flush()

unmapped_channel_ids = []

class XmltvReader:


    def __init__(self, mapping_to_channels):
        self.mapping_to_channels = mapping_to_channels
        self.channel_from_name = {}
        for channel in Channel.query.all():
            self.channel_from_name[safe_value(channel.name)] = channel

    def read(self, file_name):

        logger().debug("Clearing programmes table")
        Programme.clear

        logger().debug("Parsing EPG")
        start = time.time()
        tree = xml.parse(file_name)
        finish = time.time()
        logger().info("Parsed EPG in {} seconds".format((finish-start)))

        # Programme.transaction
        #with db.session.begin():
        #admin = User('admin')
        #db.session.add(admin)

        programmes = tree.getroot().findall("./programme")
        total = len(programmes)
        logger().info("Building model from {} 'programme's...".format(total))

        current = 0
        doCommit = False

        try:
            for programme in programmes:
                if programme == programmes[-1]:
                    doCommit = True

                self._process_programme(programme, doCommit)
                current += 1
                update_progress(100*current/total)
        finally:
            #Clear the progress bar from the terminal when done
            with t.location(0, t.height - 1):
                sys.stdout.write('{}'.format(' '* (width + 7)))
                sys.stdout.flush()

   # private
    def _process_programme(self, programmeNode, doCommit=False):
        global unmapped_channel_ids
        channel_id = programmeNode.attrib['channel']

        if str(channel_id) in self.mapping_to_channels:
            channelName = self.mapping_to_channels[str(channel_id)] ## mapping_to_channels['www.ontv.dk/tv/10342'] -> tv3 hd
            if channelName:
                self._add_programme(channelName, programmeNode, doCommit)
        else:
            if str(channel_id) not in unmapped_channel_ids:
                unmapped_channel_ids.append(str(channel_id))
                sys.stdout.write("\n")
                sys.stdout.flush()
                logger().warn("mapping_to_channels does not contain xmltv-id {}. All programmes on this channel will be skipped".format(str(channel_id)))

    def _add_programme(self, channelName, programmeNode, doCommit=False):
        title_node = None
        subtitle_node = None
        description_node = None

        title_node = programmeNode.find("./title")
        subtitle_node = programmeNode.find("./sub-title")
        description_node = programmeNode.find("desc")

        title = title_node.text
        subtitle = subtitle_node.text if subtitle_node is not None else ''
        description = description_node.text if description_node is not None else ''

        start_time = parse(programmeNode.attrib['start'])
        stop_time = parse(programmeNode.attrib['stop'])
        duration = timestamp(stop_time) - timestamp(start_time)

        channel = self._channel_from_name(channelName)

        prg = Programme(channel, title, subtitle, description, start_time, duration)
        prg.add(doCommit)
#        Programme.add(prg, channel, title, subtitle, description, start_time, duration)

    def _channel_from_name(self, channel_name):
        channel = self.channel_from_name[safe_value(channel_name)]
        if not channel:
          raise Exception, "Unknown channel: #{channel_name}"
        return channel
