# -*- coding: <utf-8> -*-

#from .database_schedule_reader import DatabaseScheduleReader

from string import maketrans

from .server import db

from .recording import Recording
from .recording_planner import RecordingPlanner
from .recording_manager import RecordingManager

from .recorder import Recorder
from .scheduler import Scheduler
from .hdhomerun import HDHomeRun

from .channel import Channel
from .category import Category
from .programme import Programme
from .schedule import Schedule

from .pvr_initializer import setup

from .database_initializer import *

def get_config_dir():
    from .server import app
    return os.path.abspath(app.config['CONFIG_DIR'])

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
            print(u"safe_value unable to handle " + x)
            return "TODO - fix encoding!!!"

def to_utf8(myStr):
    if isinstance(myStr, basestring):
        ## myStr is either str or unicode
        if isinstance(myStr, str):
            return myStr.decode('utf-8', errors='replace')
        else:
            return myStr

def json_friendly_tuple(x):
    from collections import namedtuple
    from datetime import datetime, date
    from dateutil.tz import tzlocal

    if not x:
        return None

#    ProgrammeInformationTuple = namedtuple('ProgrammeInformation', x.keys())
    ProgrammeInformationTuple = namedtuple('ProgrammeInformation', ['id', 'title', 'start_time', 'duration'])

    ## Convert datetime.datetime and datetime.date instances to strings - datetime.datetime is not JSON serializable
    tmp_dict = dict.fromkeys(x.keys())
    for idx, key in enumerate(x.keys()):
        if isinstance(x[idx], datetime) or isinstance(x[idx], date):
            tmp_dict[key] = x[idx].replace(tzinfo=tzlocal()).isoformat()
        else:
            tmp_dict[key] = x[idx]

    return ProgrammeInformationTuple(tmp_dict['id'], tmp_dict['title'], tmp_dict['start_time'], tmp_dict['duration'])



def safe_replace(to_translate, chars_to_replace = u'\\\"\'*./:', translate_to=u'_'):
    #chars_to_replace = u'!"#%\'()*+,-./:;<=>?@[\]^_`{|}~'

    if isinstance(to_translate, unicode):
        translate_table = dict((ord(char), unicode(translate_to))
            for char in chars_to_replace)
    else:
        assert isinstance(to_translate, str)
        translate_table = maketrans(chars_to_replace, translate_to*len(chars_to_replace))
    return to_translate.translate(translate_table)
