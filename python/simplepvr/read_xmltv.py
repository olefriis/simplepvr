import yaml
import codecs
import sys

#from simple_pvr.pvr_initializer import setup
from simple_pvr.xmltv_reader import XmltvReader
from simple_pvr.database_initializer import *
from simple_pvr.pvr_logger import logger
import time

db.create_all()

if len(sys.argv) != 3:
    print("Requires two arguments: The XMLTV file name, and the channel mapping file name")
    sys.exit(1)

##Fixme - do we need setup?
#setup()
try:
    stream = file(sys.argv[2], 'r')
    mapping_to_channels = yaml.load(stream)

    reader = XmltvReader(mapping_to_channels)

    xmltv_file = sys.argv[1]

    start_time = time.time()
    reader.read(xmltv_file)
    end_time = time.time()

    print "Imported EPG in {0} seconds".format((end_time-start_time))
    sys.exit(0)
except Exception, err:
    logger().error("Failed importing EPG data - reason {0}".format(str(err)))
    sys.exit(1)