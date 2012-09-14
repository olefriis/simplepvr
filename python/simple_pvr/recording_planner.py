from datetime import timedelta

class RecordingPlanner:

    def __init__(self):
         self._recordings = []

    
    def simple(self, title, channel, start_time, duration):
        self._add_recording(self, title, channel, start_time, duration)

    
    def specification(self, title, channel):
        from .master_import import Programme
      #title, channel = options[:title], options[:channel]
        if channel:
            self._schedule_programmes(title, Programme.on_channel_with_title(channel, title))
        else:
            self._schedule_programmes(title, Programme.with_title(title))

    def finish(self):
        from .pvr_initializer import scheduler
        scheduler().recordings(self._recordings)

    #private
    def _schedule_programmes(self, title, programmes):
        for programme in programmes:
            start_time = programme.startTime - timedelta(minutes = 2)
            duration = programme.duration + timedelta(minutes = 7).seconds
            self._add_recording(title, programme.channel, start_time, duration, programme)

    def _add_recording(self, title, channel, start_time, duration, programme=None):
        from .master_import import Recording
        self._recordings.append(Recording(channel, title, start_time, duration, programme))
