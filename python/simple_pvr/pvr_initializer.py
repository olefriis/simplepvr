from datetime import timedelta
import os
from time import sleep

from .master_import import HDHomeRun
from .master_import import RecordingManager
from .master_import import Scheduler

from .server import app

__hdhomerun = HDHomeRun()
recordings_path = app.config['RECORDINGS_PATH'] if 'RECORDINGS_PATH' in app.config else None
__recording_manager = RecordingManager(recordings_directory=recordings_path)
__scheduler = Scheduler()

def scheduler():
    return __scheduler

def recording_manager():
    return __recording_manager

def hdhomerun():
    return __hdhomerun

def setup():
    from .master_import import Channel

    __scheduler.setDaemon(True)
    __scheduler.start()

    if not Channel.query.all():
        __hdhomerun.scan_for_channels()

def sleep_forever():
    forever = timedelta(days=6000)
    sleep(forever)