from datetime import timedelta

class RecordingPlanner:

    def __init__(self):
         self._recordings = []

    def read(self):
        from .master_import import Schedule, Programme

        self._recordings = []
        specifications = Schedule.query.filter(Schedule.type == 'specification').all()
        exceptions = Schedule.query.filter(Schedule.type == 'exception').all()
        for specification in specifications:
            title = specification.title
            if specification.channel and specification.start_time:
                programmes = Programme.on_channel_with_title_and_start_time(specification.channel, specification.title, specification.start_time)
            elif specification.channel:
                programmes = Programme.on_channel_with_title(specification.channel, specification.title)
            else:
                programmes = Programme.with_title(specification.title)

            programmes_with_exceptions_removed = programmes ## TODO filter exception programmes
            self._add_programmes(title, programmes_with_exceptions_removed)

            from .pvr_initializer import scheduler
            scheduler().recordings(self._recordings)

    def simple(self, title, channel, start_time, duration):
        self._add_recording(self, title, channel, start_time, duration)


    #private
    def _matches_exception(self, programme, exceptions):
        match = False
        for exception in exceptions:
            match = (programme.title == exception.title and programme.channel == exception.channel and programme.start_time == exception.start_time)
            if match:
                return True
        return False

    def _add_programmes(self, title, programmes):
        for programme in programmes:
            start_time = programme.start_time - timedelta(minutes = 2)
            duration = programme.duration + timedelta(minutes = 7).seconds
            self._add_recording(title, programme.channel, start_time, duration, programme)

    def _add_recording(self, title, channel, start_time, duration, programme=None):
        from .master_import import Recording
        self._recordings.append(Recording(channel, title, start_time, duration, programme))
