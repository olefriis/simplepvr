import os
import re
import sys
import yaml
import codecs
import xml.etree.ElementTree as xml
import jellyfish
import logging

#class PvrLogger:
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.DEBUG)
logger = logging.getLogger(__name__)

def read_channels_file(file_name):
    file_exists(file_name, "Channels file '" + file_name + "' does not exist")
    channel_frequency = None
    file = codecs.open(file_name, "r")
    count = 0
    for line in file:
        scanning_search = re.search(r'^SCANNING: (\d*) .*$', line)
        program_search = re.search(r'^PROGRAM (\d*): \d* (.*)$', line)
        if scanning_search:
            channel_frequency = int(scanning_search.group(1))
        elif program_search:
            channel_id = int(program_search.group(1))
            channel_name = program_search.group(2).strip()
            if not "encrypted" in channel_name and not "$" in channel_name:
                data.append({'HDHomeRun Channel' : {'id': count, 'freq' : channel_frequency, 'program': channel_id, 'name':channel_name}})
                hdhr_names.append( channel_name )
                logger.debug("Program[id: {}]: [ freq: {}, program: {}, name: {} ]".format(count, channel_frequency, channel_id, channel_name))
                count += 1

def read_xmltv(file_name):
    element_tree = xml.parse(file_name)

    for channel in element_tree.getroot().findall('channel'):
        match_scores = []
        name__text = channel.find('display-name').text
        stripped_name = name__text.replace(" ", "")

        for hdhr_name in hdhr_names:
            stripped_hdhr_name = hdhr_name.replace(" ", "")
            score = jellyfish.jaro_winkler(stripped_name, stripped_hdhr_name)
            match_scores.append(score)

        maxValue = max(match_scores)
        maxIdx = match_scores.index(maxValue)

        logger.debug("Using hdhr_ref {} ({}) for XMLTV channel {} - score of {}".format(maxIdx, hdhr_names[maxIdx], name__text, maxValue))
        channelinfo = {'XMLTV Mapping' : {'id' : channel.attrib['id'], 'name' : name__text, 'hdhr_ref' :  maxIdx}}
        data.append(channelinfo)

    #Write HDHR channels, and XMLTV mappings to yaml file
    yaml.dump(data, yamlFile, default_flow_style=False)

    print("Done - results available in '" + yamlFile.name + "'")

def file_exists(file_path, desc = "File does not exist"):
    if not os.path.exists(file_path):
        print desc
        sys.exit(1)


if len(sys.argv) != 3:
    print("Usage:\n\t python " + sys.argv[0] + " <xmltv_file> <hdhr_scan_file>\n")
    sys.exit(1)


yamlFile = codecs.open('mapping.yaml', 'w')

data = []
hdhr_names = []

xmltv_file = sys.argv[1]
channels_file = sys.argv[2]
file_exists(xmltv_file, "XMLTV file '{}' does not exist".format(xmltv_file))
file_exists(channels_file, "HDHR channels file '{}' does not exist".format(channels_file))

read_channels_file(channels_file)
read_xmltv(xmltv_file)

