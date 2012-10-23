# -*- coding: <utf-8> -*-

from datetime import datetime,timedelta
import time


class Recording:

    channel = None
    show_name = None
    start_time = None
    stop_time = None
    duration = None
    programme = None
    schedule = None

    def __init__(self, channel, show_name, start_time, stop_time, duration, programme, schedule=None):
        self.channel = channel
        self.show_name = show_name
        self.start_time = start_time
        self.stop_time = stop_time
        self.duration = duration
        self.programme = programme
        self.schedule = schedule

    def __str__(self):
        from .master_import import to_utf8
        return u"'{0}' from '{1}' at '{2}'".format(to_utf8(self.show_name), self.channel, self.start_time)

    def expired(self):
        return self.expired_at(datetime.now()) #(self.start_time + timedelta(seconds = self.duration)) < datetime.now()

    def expired_at(self, time):
        #return self._end_time() < time
        return self.stop_time <= time

    def inspect(self):
        from .master_import import to_utf8
        return u"'{0}' from '{1}' at '{2}'".format(to_utf8(self.show_name), self.channel, self.start_time)

    def __cmp__(self, other):
        if self is other:
            return 0
        if other is None:
            return 1
        return (self.start_time - other.start_time).seconds

    def __hash__(self):
        return hash((self.show_name, self.start_time, self.stop_time, self.programme))

    def _end_time(self):
        return self.start_time + timedelta(seconds = self.duration)

    def __repr__(self):
        return u'<Recording serialized: %s>' % (self.serialize)

    def is_recording_of_schedule(self, schedule):
        from .recording_planner import RecordingPlanner
        matches = self.show_name == schedule.title

        if schedule.channel:
            matches &= (self.channel.id == schedule.channel.id)

        if schedule.start_time and schedule.stop_time:
            ## remember to adjust for early start and run
            recording_schedule_start_time = self.start_time + timedelta(minutes=RecordingPlanner.MINUTES_START_BEFORE)
            recording_schedule_stop_time = self.stop_time - timedelta(minutes=RecordingPlanner.MINUTES_CONTINUE_AFTER)

            matches &= (recording_schedule_start_time == schedule.start_time and recording_schedule_stop_time == schedule.stop_time)

        return matches

    @property
    def serialize(self):
        from .master_import import safe_value
        from dateutil.tz import tzlocal
        """Return object data in easily serializeable format"""

        return {
            'show_name': safe_value(self.show_name),
            'channel'  : self.channel.serialize if self.channel else None,
            'start_time'  : self.start_time.replace(tzinfo=tzlocal()).isoformat() if self.start_time else None,
            'stop_time'  : self.stop_time.replace(tzinfo=tzlocal()).isoformat() if self.stop_time else None,
            'duration'  : self.duration,
            'programme'  : self.programme.serialize if self.programme else None,
            'schedule'  : self.schedule.serialize if self.schedule else None
        }
