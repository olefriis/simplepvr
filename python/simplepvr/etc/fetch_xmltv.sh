#!/bin/sh

URL_XMLTV_DATA="http://service_where_you_can_get_xmltv_data_from"

curl -o epg.xml -L "${URL_XMLTV_DATA}"

echo "Done"