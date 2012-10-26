#!/bin/bash

if [ $# != 1 ]; then
	echo "Usage: 
		$0 epg.xml 
	Result is stored in channel_mappings.yaml file in current dir"
 	exit 0
fi

if [ -f "$1" ]; then
	OUTFILE='channel_mappings.yaml'
	echo "# Mappings generated from XMLTV file '$1' 
# 
# NOTE: The channel names in the generated file are just there to assist you in completing the mappings. 
# The generated names must be replaced with the names that SimplePVR uses (which in turn are retrieved 
# from the HDHomerun).
#
# The names from the database can be retrieved by running:
# 	sqlite3 ~/.simplepvr/simplepvr.sqlite 'select name from channels WHERE hidden = 0 ORDER BY name'
# or if sqlite3 command is not available, use the python channel_names script:
#	python channel_names.py ~/.simplepvr/simplepvr.sqlite
# 
#" > "${OUTFILE}"

	xmllint --xpath "//channel/@id | //channel/display-name/text() " "$1" | awk '{gsub("id=","\nid=");printf"%s",$0}' | sed '/^$/d' | sed 's|id="\([a-zA-Z0-9/\.]*\)"\([\w]*\)|\1: \2|' >> "${OUTFILE}"
	echo "Done  -  Result available in channel_mappings.yaml"
	echo "   - Next step is to fix the channel names in the file, see the inlined comments describing how to do it."
else
	echo "File '$1' not found - fix the path and try again"
	exit 1
fi

