from .pvr_initializer import pvr_initializer
from .pvr_logger import logger

class Recorder:
    def __init__(self, tuner, recording):
        self.tuner = tuner
        self.recording = recording

    def start(self):
        directory = pvr_initializer().recording_manager().create_directory_for_recording(self.recording)
        pvr_initializer().hdhomerun().start_recording(self.tuner, self.recording.channel.frequency, self.recording.channel.channel_id, directory)

        logger().info("Started recording {0} in {1}".format(recording.show_name, directory))

    def stop(self):
        pvr_initializer().hdhomerun().stop_recording(self.tuner)

        logger().info("Stopped recording {0}".format(recording.show_name))