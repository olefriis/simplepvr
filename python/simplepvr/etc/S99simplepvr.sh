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

PYTHON_EXEC="/opt/bin/python2.6"
SIMPLEPVR_DAEMON_SCRIPT="/volume1/@appstore/simplepvr/python/simplepvr/simplepvr_daemon.py"
CONFIG_FILE="/volume1/@appstore/.simplepvr/simplepvr.cfg"

case "$1" in
  start)
    echo "Starting server"
    # Start the daemon
    CONF="${CONFIG_FILE}" "${PYTHON_EXEC}" "${SIMPLEPVR_DAEMON_SCRIPT}" start
    ;;
  stop)
    echo "Stopping server"
    # Stop the daemon
    CONF="${CONFIG_FILE}" "${PYTHON_EXEC}" "${SIMPLEPVR_DAEMON_SCRIPT}" stop
    ;;
  restart)
    echo "Restarting server"
    CONF="${CONFIG_FILE}" "${PYTHON_EXEC}" "${SIMPLEPVR_DAEMON_SCRIPT}" restart
    ;;
  *)
    # Refuse to do other stuff
    echo "Usage: $0 {start|stop|restart}"
    exit 1
    ;;
esac

exit 0