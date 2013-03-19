# -*- coding: <utf-8> -*-

from datetime import timedelta

class RecordingPlanner:
    MINUTES_START_BEFORE=2
    MINUTES_CONTINUE_AFTER=3

    def __init__(self):
         self._recordings = []

    def read(self):
        from .master_import import Schedule, Programme
        from datetime import datetime
        from sqlalchemy import or_

        self._recordings = []

        clauses = [Schedule.stop_time == None, Schedule.stop_time >= datetime.now()]

        specifications = Schedule.query.filter(Schedule.type == 'specification').filter( or_(*clauses) ).all()
        exceptions = Schedule.query.filter(Schedule.type == 'exception').filter( or_(*clauses) ).all()
        for specification in specifications:
            title = specification.title
            if specification.channel and specification.start_time:
                programmes = Programme.on_channel_with_title_and_start_time(specification.channel, specification.title, specification.start_time)
            elif specification.channel:
                programmes = Programme.on_channel_with_title(specification.channel, specification.title)
            else:
                programmes = Programme.with_title(specification.title)

            programmes_with_exceptions_removed = self.remove_excluded_programmes(programmes, exceptions) #programmes ## TODO filter exception programmes
            self._add_programmes(title, programmes_with_exceptions_removed, specification)

        if self._recordings:
            from .pvr_initializer import scheduler
            scheduler().recordings(self._recordings)

    def simple(self, title, channel, start_time, duration):
        self._add_recording(self, title, channel, start_time, duration)

    def remove_excluded_programmes(self, programmes, exceptions):
        for programme in programmes:
            if self._matches_exception(programme, exceptions):
                programmes.remove(programme)
        return programmes

    #private
    def _matches_exception(self, programme, exceptions):
        match = False
        for exception in exceptions:
            match = (programme.title == exception.title and programme.channel == exception.channel and programme.start_time == exception.start_time)
            if match:
                return True
        return False

    def _add_programmes(self, title, programmes, schedule):
        for programme in programmes:
            start_time = programme.start_time - timedelta(minutes = RecordingPlanner.MINUTES_START_BEFORE)
            stop_time = programme.stop_time + timedelta(minutes = RecordingPlanner.MINUTES_CONTINUE_AFTER)
            duration = (stop_time-start_time).seconds
            self._add_recording(title, programme.channel, start_time, stop_time, duration, programme, schedule)
        self._recordings.sort(key=lambda rec: rec.start_time)

    def _add_recording(self, title, channel, start_time, stop_time, duration, programme=None, schedule=None):
        from .master_import import Recording
        self._recordings.append(Recording(channel=channel, show_name=title, start_time=start_time, stop_time=stop_time, duration=duration, programme=programme, schedule=schedule))
