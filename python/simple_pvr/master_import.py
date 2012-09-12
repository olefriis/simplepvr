from .pvr_initializer import PvrInitializer
from .database_schedule_reader import DatabaseScheduleReader


from .server import db

from .recording import Recording
from .recording_planner import RecordingPlanner
from .recording_manager import RecordingManager
from .recorder import Recorder
from .scheduler import Scheduler
from .hdhomerun import HDHomeRun

from .channel import Channel
from .programme import Programme
from .schedule import Schedule


def safe_value(x):
    """ Do not die on bad input """
    try:
        if type(x) == str:
            return x
        else:
            return x.decode("utf-8")
    except UnicodeError:
        try:
            return x.encode("utf-8")
        except UnicodeError:
            return "TODO - fix encoding!!!"