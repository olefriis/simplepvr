from datetime import datetime,timedelta
import time


class Recording:

    channel = None
    show_name = None
    start_time = None
    duration = None
    programme = None

    def __init__(self, channel, show_name, start_time, duration, programme):
        self.channel = channel
        self.show_name = show_name
        self.start_time = start_time
        self.duration = duration
        self.programme = programme

    def __str__(self):
        return "'{0}' from '{1}' at '{2}'".format(self.show_name, self.channel, self.start_time)

    def expired(self):
        return self.expired_at(datetime.now()) #(self.start_time + timedelta(seconds = self.duration)) < datetime.now()

    def expired_at(self, time):
        return self._end_time() < time

    def inspect(self):
        return "'{0}' from '{1}' at '{2}'".format(self.show_name, self.channel, self.start_time)

    def __cmp__(self, other):
        if self is other:
            return 0
        if other is None:
            return 1
        return (self.start_time - other.start_time).total_seconds()

    def __hash__(self):
        return hash((self.show_name, self.start_time, self.programme))

    def _end_time(self):
        return self.start_time + timedelta(seconds = self.duration)