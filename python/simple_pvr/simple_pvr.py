
def schedule(block=""):
    from simple_pvr import PvrInitializer
    PvrInitializer.setup
    pvr = SimplePvr()
    pvr.instance_eval &block
    pvr.finish

    PvrInitializer.sleep_forever



class SimplePvr:
    def __init__(self):
        from .master_import import RecordingPlanner
        self._recording_planner = RecordingPlanner()


    def record(self, show_name, atTime=None, fromTime = None, forTime = None):
        if (atTime is None and fromTime is None):
            self._record_programmes_with_title(show_name)
        elif (atTime is None):
            self._record_programmes_with_title_on_channel(show_name, fromTime)
        else:
            self._record_from_timestamp_and_duration(show_name, fromTime, atTime, forTime)


    def finish(self):
        self._recording_planner.finish()

#private
    def _record_programmes_with_title(self, title):
        self._recording_planner.specification(title)


    def _record_programmes_with_title_on_channel(self, title, channel_name):
        from .master_import import Channel
        channel = Channel.with_name(channel_name)
        self._recording_planner.specification(title, channel)

    def _record_from_timestamp_and_duration(self, show_name, channel_name, start_time, duration = None):
        from .master_import import Channel
        if duration is None:
            raise Exception, "No duration specified for recording of '#{show_name}' from '#{channel_name}' at '#{start_time}'"

        channel = Channel.with_name(channel_name)
        self._recording_planner.simple(show_name, channel, start_time, duration)
