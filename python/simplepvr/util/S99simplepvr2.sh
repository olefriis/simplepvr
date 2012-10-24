#!/bin/bash
# /etc/rc.d/cloudprint
# Description: Starts the Google Cloud Print script on startup
# ----------------
#
### BEGIN INIT INFO
# Provides: Cloud-Print
# Required-Start: $cups $network $local_fs $syslog
# Required-Stop: $local_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Description: Start Google Cloud Print
### END INIT INFO

case $1 in
   start)
      echo -n "Starting Google Cloud Print: "
      CONF=/opt/etc/simplepvr.cfg /opt/bin/python2.6 /opt/share/simplepvr/python/simplepvr/
      sudo -u cloudprint /home/cloudprint/cloudprint/cloudprint.py -d -p /home/cloudprint/cloudprint.pid
   ;;
   stop)
      echo -n "Stopping Google Cloud Print: "
      kill `cat /home/cloudprint/cloudprint.pid`
   ;;
   restart)
      echo -n "Restarting Google Cloud Print: "
        $0 stop
        $0 start
   ;;
   *)
        echo "Usage: cloudprint {start|stop|restart}"
   ;;
esac