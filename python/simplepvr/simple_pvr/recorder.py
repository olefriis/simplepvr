from .pvr_logger import logger

class Recorder(object):
    def __init__(self, tuner, recording):
        self.tuner = tuner
        self.recording = recording

    def start(self):
        print "Starting recording"
        from .pvr_initializer import recording_manager, hdhomerun
        directory = recording_manager().create_directory_for_recording(self.recording)
        hdhomerun().start_recording(self.tuner, self.recording.channel.frequency, self.recording.channel.channel_id, directory)

        logger().info("Started recording {0} in {1}".format(self.recording.show_name, directory))

    def stop(self):
        from .pvr_initializer import hdhomerun
        hdhomerun().stop_recording(self.tuner)

        logger().info("Stopped recording {0}".format(self.recording.show_name))

    def __hash__(self):
        return hash((self.tuner, self.recording))