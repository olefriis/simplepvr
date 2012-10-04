import sys
from simple_pvr.pvr_initializer import setup, recording_manager
from simple_pvr import RecordingManager
from simple_pvr.database_initializer import *

def main(argv=None):
    db.create_all()

    print "pvr initializer setup"
    setup()

    print "Server running on main thread"
    from simple_pvr import server
    server.startServer()
    server.reload_schedules()

if __name__ == "__main__":
    sys.exit(main())
