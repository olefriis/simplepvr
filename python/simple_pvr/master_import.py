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
            print("safe_value unable to handle " + x)
            return "TODO - fix encoding!!!"

def safe_replace(to_translate, chars_to_replace = u'\\\"\'*./:', translate_to=u'_'):
    #chars_to_replace = u'!"#%\'()*+,-./:;<=>?@[\]^_`{|}~'

    if isinstance(to_translate, unicode):
        translate_table = dict((ord(char), unicode(translate_to))
            for char in chars_to_replace)
    else:
        assert isinstance(to_translate, str)
        translate_table = string.maketrans(chars_to_replace,
                                           translate_to
                                           *len(chars_to_replace))
    return to_translate.translate(translate_table)
