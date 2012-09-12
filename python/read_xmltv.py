import yaml
import codecs
import sys

from simple_pvr.pvr_initializer import pvr_initializer
from simple_pvr.xmltv_reader import XmltvReader

if len(sys.argv) != 3:
    print("Requires two arguments: The XMLTV file name, and the channel mapping file name")
    sys.exit(1)

pvr_initializer().setup

stream = file(sys.argv[2], 'r')
mapping_to_channels = yaml.load(stream)

reader = XmltvReader(mapping_to_channels)

xmltv_file = sys.argv[1]
reader.read(xmltv_file)