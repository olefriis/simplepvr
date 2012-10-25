# -*- coding: <utf-8> -*-

import yaml
import codecs
import sys

from simple_pvr.xmltv_reader import XmltvReader
from simple_pvr.database_initializer import *
from simple_pvr.pvr_logger import logger
import time

def import_epg(xmltv_file, channel_mappings_file):
    mapping_to_channels = yaml.load(file(channel_mappings_file, 'r'))
    reader = XmltvReader(mapping_to_channels)

    start_time = time.time()
    reader.read(xmltv_file)
    end_time = time.time()

    print "Imported EPG in {0} seconds".format((end_time-start_time))



def main(argv=None):
#    from multiprocessing import Process
    import threading

    if not argv or len(argv) != 3:
        print("Requires two arguments: The XMLTV file name, and the channel mapping file name")
        sys.exit(1)

    #import_epg(xmltv_file=argv[1], channel_mappings_file=argv[2])
    #p = Process(target=import_epg, args=(argv[1], argv[2],))
    

    p = threading.Thread(target=import_epg, args=(argv[1], argv[2],))
    print "Importing EPG"
    p.start()
    p.join()



if __name__ == "__main__":
    sys.exit(main(sys.argv))
