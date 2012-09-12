import os
import sys
sys.path.append(os.curdir)


def start():
    from simple_pvr import DatabaseScheduleReader,server, pvr_initializer

    pvr_initializer().setup

    if pvr_initializer().hdhomerun() is None or pvr_initializer().scheduler() is None or pvr_initializer().recording_manager() is None:
        raise Exception(pvr_initializer())

    DatabaseScheduleReader().read()

    server.run()

if __name__ == '__main__':
    start()