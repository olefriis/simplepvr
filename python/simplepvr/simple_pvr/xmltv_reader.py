# -*- coding: <utf-8> -*-

import codecs, sys
from datetime import datetime
import xml.etree.ElementTree as xml
from dateutil.parser import parse
from dateutil.tz import tzlocal
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
    if (t is None or t.height is None):
        print ('[{0}{1}] {2}%'.format('#'* hashes, ' '* spaces, progress))
        return ''
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
        Programme.clear()

        logger().debug("Parsing EPG")
        start = time.time()
        tree = xml.parse(file_name)
        finish = time.time()
        logger().info("Parsed EPG in {0} seconds".format((finish-start)))

        start = finish
        categories = tree.getroot().getiterator("category")
        self._process_categories(categories)
        finish = time.time()
        logger().info("Categories processed in {0}".format((finish-start)))

        start = finish
        channels = tree.getroot().findall("./channel")
        self._process_channels(channels)
        finish = time.time()
        logger().info("Channels processed in {0}".format((finish-start)))

        start = finish
        programmes = tree.getroot().findall("./programme")
        total = len(programmes)
        logger().info("Building model from {0} programmes".format(total))

        current = 0
        doCommit = False
        err = None
        try:
            progress_value = 0
            commit_idx = total-1
            for programme in programmes:
                if current == commit_idx:
                    doCommit = True

                self._process_programme(programme, doCommit)
                current += 1

                progress = (100 * current) / total
                if ((progress - progress_value) > 0):
                    update_progress(progress)
                progress_value = progress
        except Exception, err:
            raise err
        finally:
            #Clear the progress bar from the terminal when done
            if err:
                raise err

            finish = time.time()
            logger().info("Programmes processed in {0} seconds".format((finish-start)))

            if t is None or t.height is None:
                return

            with t.location(0, t.height - 1):
                sys.stdout.write('{0}'.format(' '* (width + 7)))
                sys.stdout.flush()

    def _process_categories(self, categoryNodes):
        from .master_import import Category
        categories = set()
        start_nodes = time.time()
        for category in categoryNodes:
            categories.add(category.text.title())
        end_nodes = time.time()
        logger().info("Added categories in {0} seconds".format((end_nodes-start_nodes)))
        last_elem = list(categories)[-1]

        logger().debug("Adding categories to database")
        start_cat_db = time.time()
        for cat_txt in categories:
            cat = Category(cat_txt)
            if cat_txt == last_elem:
                start_commit = time.time()
                cat.add(commit=True)
                end_commit = time.time()
                logger().info("Committed categories to db in {0} seconds".format((end_commit-start_commit)))
            else:
                cat.add(commit=False)
        end_cat_db = time.time()
        logger().info("Added categories to database in {0} seconds".format((end_cat_db-start_cat_db)))

    def _process_channels(self, channels):
        for channelNode in channels:
            channel_id = channelNode.attrib['id']
            icon_node = channelNode.find("./icon")
            icon_url = icon_node.attrib['src'] if icon_node is not None else None
            str_channel_id = str(channel_id)
            if str_channel_id in self.mapping_to_channels:
                channelName = self.mapping_to_channels[str(channel_id)]
            else:
                logger().error(u"Channel id '{0}' is not in mappings file - channel data can not be imported till a mapping for {1} is added to 'channel_mappings.yaml'".format(str_channel_id, str_channel_id))
                continue

            channel = Channel.with_name(channelName)
            channel.icon_url = icon_url
            channel.save()

    def unique(self, seq): # Dave Kirby
        # Order preserving
        seen = set()
        return [x for x in seq if x not in seen and not seen.add(x)]

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
                logger().warn(u"mapping_to_channels does not contain xmltv-id {0}. All programmes on this channel will be skipped".format(str(channel_id)))

    def _add_programme(self, channelName, programmeNode, doCommit=False):
        title_node = None
        subtitle_node = None
        description_node = None

        title_node = programmeNode.find("./title")
        subtitle_node = programmeNode.find("./sub-title")
        description_node = programmeNode.find("desc")
        episodenum_node = programmeNode.find("episode-num")

        serie = False
        categories = []
        for category in programmeNode.findall("./category"):
            category_text = category.text.title()
            if category_text == 'serie'.title():
                serie = True
            else:
                ## Only add category when it is not 'Serie' as serie is handled in a dedicated field
                categories.append(category_text)

        title = title_node.text
        subtitle = subtitle_node.text if subtitle_node is not None else ''
        description = description_node.text if description_node is not None else ''
        episode_number = episodenum_node.text if episodenum_node is not None else ''


        start_time = parse(programmeNode.attrib['start']).astimezone(tz=tzlocal()) ## astimezone added to handle cases when epg dates are in utc, astimezone also handles offsets like +0200 nicely
        stop_time = parse(programmeNode.attrib['stop']).astimezone(tz=tzlocal())
        duration = timestamp(stop_time) - timestamp(start_time)

        channel = self._channel_from_name(channelName)

        prg = Programme(channel, title, subtitle, description, start_time, stop_time, duration, episode_num=episode_number, series=serie, categories=categories)
        prg.add(doCommit)


    def _channel_from_name(self, channel_name):
        channel = self.channel_from_name[safe_value(channel_name)]
        if not channel:
          raise Exception, u"Unknown channel: #{channel_name}"
        return channel
