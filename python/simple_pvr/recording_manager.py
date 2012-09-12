#require 'active_support/all'
import codecs
from collections import namedtuple
import os
from shutil import rmtree
from sys import path
import yaml

from .pvr_logger import logger

RecordingMetadata = namedtuple('RecordingMetadata', ['show_name', 'episode', 'channel', 'subtitle', 'description', 'start_time', 'duration'])

class RecordingManager:
    def __init__(self, recordings_directory=None):
        self.recordings_directory = recordings_directory if recordings_directory is not None else os.curdir + "/recordings"
        #self.recordings_directory = recordings_directory || Dir.pwd + '/recordings'

    def shows(self):
        if (os.path.exists(self.recordings_directory)):
            return os.listdir(self.recordings_directory)
        else:
            return {}

    def delete_show(self, show_name):
        rmtree(directory_for_show(show_name), ignore_errors = True)

    def episodes_of(self, show_name):
        episodes = os.listdir(self._directory_for_show(show_name))
        result = []
        for episode in episodes:
            result.append(self._metadata_for(show_name, episode))
        return result

    def delete_show_episode(self, show_name, episode):
        logger().info("Fjerner {}/{}/{}".format(self.recordings_directory, show_name, episode))
        os.remove(self.recordings_directory + "/" + show_name + "/" + episode)

    def create_directory_for_recording(self, recording):
        show_directory = directory_for_show(recording.show_name)
        ensure_directory_exists(show_directory)

        new_sequence_number = next_sequence_number_for(show_directory)
        recording_directory = "{}/{}".format(show_directory, new_sequence_number)
        ensure_directory_exists(recording_directory)

        self._create_metadata(recording_directory, recording)

        return recording_directory

#private
    def _directory_for_show(self, show_name):
        sanitized_directory_name = show_name.translate(None, "\\\"'*./:")
        logger().debug("Sanitized: {}".format(sanitized_directory_name))
        directory_name = sanitized_directory_name if os.path.exists(sanitized_directory_name) else 'Unnamed'
        self.recordings_directory + '/' + directory_name

    def _directory_for_show_and_episode(self, show_name, episode):
        return self._directory_for_show(show_name) + '/' + episode

    def _ensure_directory_exists(self, directory):
        if not os.path.exists(directory):
            os.makedirs(directory)

    def _next_sequence_number_for(self, base_directory):
        entries = os.listdir(base_directory)
        numeric_entries = []
        for entry in entries:
            numeric_entries.append(int(entry))
        largest_current_sequence_number = max(numeric_entries)
        return 1 + largest_current_sequence_number

    def _metadata_for(self, show_name, episode):
        metadata_file_name = self._directory_for_show_and_episode(show_name, episode) + '/metadata.yml'

        if os.path.exists(metadata_file_name):
            stream = file(metadata_file_name, 'r')

            metadata = yaml.load(stream)

            return RecordingMetadata(
                show_name,
                episode,
                metadata['channel'],
                metadata['subtitle'],
                metadata['description'],
                metadata['start_time'],
                metadata['duration'])
        else:
            logger().info(metadata_file_name + " does not exist - no episode metadata available")
            return {}

    def _create_metadata(self, directory, recording):
        metadata = {
            'title': recording.show_name,
            'channel': recording.channel.name,
            'start_time': recording.start_time,
            'duration': recording.duration
        }

        if recording.programme is not None:
            metadata.update({
                'subtitle': recording.programme.subtitle,
                'description': recording.programme.description
            })
        yamlFile = codecs.open(directory + '/metadata.yml', 'w')
        yaml.dump(metadata, yamlFile, default_flow_style=False)
