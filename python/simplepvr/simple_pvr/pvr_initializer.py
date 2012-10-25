# -*- coding: <utf-8> -*-

from .config import config

from datetime import timedelta
import os
from time import sleep

from .master_import import HDHomeRun
from .master_import import RecordingManager
from .master_import import Scheduler

from .server import app

_config_recordings_path = config.get('SimplePVR', 'recordings_path')

__hdhomerun = HDHomeRun()
recordings_path = _config_recordings_path
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