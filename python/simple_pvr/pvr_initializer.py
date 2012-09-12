from datetime import timedelta
from time import sleep

__pvrInitializer = None

def pvr_initializer():
    from .master_import import HDHomeRun, RecordingManager, Scheduler
    global __pvrInitializer
    if __pvrInitializer is None:
        __pvrInitializer = PvrInitializer(HDHomeRun(), RecordingManager(), Scheduler())
    return __pvrInitializer


class PvrInitializer(object):

    def __init__(self, hdhomerun = None, recording_manager = None, scheduler = None):
        self._hdhomerun = hdhomerun
        self._recording_manager = recording_manager
        self._scheduler = scheduler


    @staticmethod
    def setup():
        from .master_import import Channel

        pvr_initializer().scheduler().start()

        if not Channel.query.all():
            pvr_initializer().hdhomerun().scan_for_channels()

    def hdhomerun(self):
        return self._hdhomerun

    def recording_manager(self):
        return self._recording_manager

    def scheduler(self):
        return self._scheduler

    def sleep_forever(self):
        forever = timedelta(days=6000)
        sleep(forever)