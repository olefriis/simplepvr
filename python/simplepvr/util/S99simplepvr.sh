#! /bin/bash
# Copyright (c) 1996-2012 My Company.
# All rights reserved.
#
# Author: Bob Bobson, 2012
#
# Please send feedback to bob@bob.com
#
# /etc/init.d/simplepvr
#
### BEGIN INIT INFO
# Provides: simplepvrdaemon
# Required-Start:
# Should-Start:
# Required-Stop:
# Should-Stop:
# Default-Start:  3 5
# Default-Stop:   0 1 2 6
# Short-Description: Test daemon process
# Description:    Runs up the test daemon process
### END INIT INFO

# Activate the python virtual environment
#    . /path_to_virtualenv/activate

case "$1" in
  start)
    echo "Starting server"
    # Start the daemon
    CONF=/opt/etc/simplepvr.cfg /opt/bin/python2.6 /opt/share/simplepvr/python/simplepvr/util/simplepvr_daemon.py start
    #python /usr/share/simplepvr/testdaemon.py start
    ;;
  stop)
    echo "Stopping server"
    # Stop the daemon
    CONF=/opt/etc/simplepvr.cfg /opt/bin/python2.6 /opt/share/simplepvr/python/simplepvr/util/simplepvr_daemon.py stop
    #python /usr/share/testdaemon/testdaemon.py stop
    ;;
  restart)
    echo "Restarting server"
    CONF=/opt/etc/simplepvr.cfg /opt/bin/python2.6 /opt/share/simplepvr/python/simplepvr/util/simplepvr_daemon.py restart
    #python /usr/share/testdaemon/testdaemon.py restart
    ;;
  *)
    # Refuse to do other stuff
    echo "Usage: $0 {start|stop|restart}"
    exit 1
    ;;
esac

exit 0