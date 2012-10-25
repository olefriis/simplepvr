# -*- coding: <utf-8> -*-

import os
import re
import sys
import yaml
import codecs
import xml.etree.ElementTree as xml
import jellyfish
import logging


#class PvrLogger:
JARO_WINKLER_THRESHOLD = 0.75
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.DEBUG)
logger = logging.getLogger(__name__)

def read_channels_file(fname):
    file_path = os.path.join(os.path.dirname(__file__), fname)

    file_exists(file_path, "Channels file '" + file_path + "' does not exist")
    channel_frequency = None
    file = codecs.open(file_path, "r")
    count = 0

    for line in file:
        scanning_entry = re.search(r'^SCANNING: (\d*) .*$', line)
        program_entry = re.search(r'^PROGRAM (\d*): \d* (.*)$', line)
        if scanning_entry:
            channel_frequency = int(scanning_entry.group(1))
        elif program_entry:
            channel_id = int(program_entry.group(1))
            channel_name = program_entry.group(2).strip()
            if not "encrypted" in channel_name and not "$" in channel_name:
                data.append({'HDHomeRun Channel' : {'id': count, 'freq' : channel_frequency, 'program': channel_id, 'name':channel_name}})
                hdhr_names.append( channel_name )
                logger.debug("Program[id: {0}]: [ freq: {1}, program: {2}, name: {3} ]".format(count, channel_frequency, channel_id, channel_name))
                count += 1


def getSafeLogString(maxIdx, maxValue, name__text):
    try:
        return "Using hdhr_ref {0} ({1}) for XMLTV channel {2} - score of {3}".format(maxIdx, hdhr_names[maxIdx], name__text,maxValue)
    except UnicodeError:
        return "Using hdhr_ref {0} for XMLTV channel".format(maxIdx)


def read_xmltv(fname):
    file_path = os.path.join(os.path.dirname(__file__), fname)
    element_tree = xml.parse(file_path)

    for channel in element_tree.getroot().findall('channel'):
        found_match = False
        match_scores = []
        name__text = channel.find('display-name').text.encode(sys.stdout.encoding)

        icon_url = channel.find('icon').attrib['src']

        stripped_name = name__text.replace(" ", "")

        for hdhr_name in hdhr_names:
            score = 0
            safe_hdhr_name = hdhr_name if is_ascii(hdhr_name) else hdhr_name.decode(sys.stdout.encoding)
            stripped_hdhr_name = safe_hdhr_name.replace(" ", "")
            try:
                score = jellyfish.jaro_winkler(stripped_name, stripped_hdhr_name )
            except UnicodeEncodeError:
                try:
                    safe_name_text = name__text if is_ascii(name__text) else name__text.decode(sys.stdout.encoding)
                    logger.warn(u"Unable to do score for '{0}' vs '{1}'".format(safe_name_text, safe_hdhr_name))
                except UnicodeEncodeError:
                    ## Hvis vi heller ikke kan logge vores error pga. encoding, logger vi en ny error der er "sikker"
                    safe_hdhr_name = to_utf8(safe_hdhr_name)
                    safe_name_text = to_utf8(safe_name_text)
                    logger.warn(u"Unable to do score calculation for {0} - {1} - console encoding: {2}".format(safe_name_text, safe_hdhr_name, sys.stdout.encoding))
#                    logger.warn(name__text, " <-> ", hdhr_name, " isAscii: ", is_ascii(hdhr_name), " -- Safe version ", safe_name_text, " - ", safe_hdhr_name, " - sys encoding: ", sys.stdout.encoding)

            match_scores.append(score)

        maxValue = max(match_scores)


        if maxValue > JARO_WINKLER_THRESHOLD:
            found_match = True
            maxIdx = match_scores.index(maxValue)
            hdhrName = hdhr_names[maxIdx]
            logger.info(getSafeLogString(maxIdx, maxValue, name__text))
            xmltvId = channel.attrib['id']
            channelinfo = {'XMLTV Mapping' : {'id' : xmltvId, 'name' : name__text, 'icon': icon_url, 'hdhr_ref' :  maxIdx, 'hdhr_name': hdhrName}}
            logger.debug("Data for maxIdx[{0}]{1}".format(maxIdx, data[maxIdx]['HDHomeRun Channel']))
            channel_mappings.update({xmltvId : hdhrName})
            data.append(channelinfo)
            hdhr_names.remove(hdhrName)
        else:
            hdhrName = hdhr_names[maxIdx]
            try:
                logger.debug("Score < {0}. Ignoring result '{1}' for '{2}' - score ({3})".format(JARO_WINKLER_THRESHOLD,
                                                                                             hdhrName, name__text, maxValue))
            except UnicodeError:
                logger.debug(name__text + " vs " + hdhrName)

    ## Insert FIXME entries for the hdhr-names that were not automatically matched to an XMLTV channel id
    count = 0
    for name in hdhr_names:
        logger.debug("No XMLTV id found for channel name '{0}'".format(name))
        channel_mappings.update({"[{0}] FIXME: XMLTV ID HERE".format(count) : name})
        count = count + 1
    #Write HDHR channels, and XMLTV mappings to yaml file
    yaml.dump(data, yamlFile, default_flow_style=False, encoding='utf-8')
    yaml.dump(channel_mappings, channelMappingFile, default_flow_style=False, encoding='utf-8')

    print("Done - results available in '" + yamlFile.name + "' and '"+ channelMappingFile.name+"'")

def to_utf8(myStr):
    if isinstance(myStr, basestring):
        ## myStr is either str or unicode
        if isinstance(myStr, str):
            return myStr.decode('utf-8', errors='replace')
        else:
            return myStr

def is_utf8(myStr):
    try:
        myStr.decode('utf-8')
    except UnicodeDecodeError:
        return False
    return True

def is_ascii(myStr):
    try:
        myStr.decode('ascii')
    except UnicodeDecodeError:
        #print "it was not a ascii-encoded unicode string"
        return False
    else:
        return True
#        print "It may have been an ascii-encoded unicode string"

def file_exists(file_path, desc = "File does not exist"):
    if not os.path.exists(file_path):
        print desc
        sys.exit(1)


if len(sys.argv) != 3:
    print("Usage:\n\t python " + sys.argv[0] + " <xmltv_file> <hdhr_scan_file>\n")
    sys.exit(1)


yamlFile = codecs.open('mapping.yaml', 'w')

channelMappingFile = codecs.open('channel_mappings.yaml', 'w')

channel_mappings = {}
data = []
hdhr_names = []

xmltv_file = sys.argv[1]
channels_file = sys.argv[2]
file_exists(xmltv_file, "XMLTV file '{0}' does not exist".format(xmltv_file))
file_exists(channels_file, "HDHR channels file '{0}' does not exist".format(channels_file))

read_channels_file(channels_file)
read_xmltv(xmltv_file)

