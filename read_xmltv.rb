require File.dirname(__FILE__) + '/lib/simple_pvr/xmltv_reader'
require File.dirname(__FILE__) + '/lib/simple_pvr/dao'
require 'yaml'

if ARGV.length != 2
  puts "Requires two arguments: The XMLTV file name, and the channel mapping file name"
  exit 1
end

xmltv_file = File.new(ARGV[0])
mapping_to_channels = YAML.load_file(ARGV[1])

reader = SimplePvr::XmltvReader.new(SimplePvr::Dao.new, mapping_to_channels)
reader.read(File.new('programmes.xmltv'))