import sys
from simple_pvr.pvr_initializer import setup
from simple_pvr import DatabaseScheduleReader
from simple_pvr.database_initializer import *

def main(argv=None):
    db.create_all()

    print "pvr initializer setup"
    setup()

    print "DatabaseScheduleReader"
    DatabaseScheduleReader().read()

    print "Server running on main thread"
    from simple_pvr import server
    server.startServer()

if __name__ == "__main__":
    sys.exit(main())
