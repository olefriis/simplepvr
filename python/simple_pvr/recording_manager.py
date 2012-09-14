import codecs
from collections import namedtuple
import os
from shutil import rmtree
import yaml

from .pvr_logger import logger

RecordingMetadata = namedtuple('RecordingMetadata', ['show_name', 'episode', 'channel', 'subtitle', 'description', 'start_time', 'duration'])

class RecordingManager:
    def __init__(self, recordings_directory=None):
        self.recordings_directory = recordings_directory if recordings_directory is not None else os.curdir + "/recordings"

    def shows(self):
        if (os.path.exists(self.recordings_directory)):
            return os.listdir(self.recordings_directory)
        else:
            return {}

    def delete_show(self, show_name):
        rmtree(self._directory_for_show(show_name), ignore_errors = True)

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
        show_directory = self._directory_for_show(recording.show_name)
        self._ensure_directory_exists(show_directory)

        new_sequence_number = self._next_sequence_number_for(show_directory)
        recording_directory = "{}/{}".format(show_directory, new_sequence_number)
        self._ensure_directory_exists(recording_directory)

        self._create_metadata(recording_directory, recording)

        return recording_directory

#private
    def _directory_for_show(self, show_name):
        from .master_import import safe_replace
        sanitized_directory_name = safe_replace(show_name)
        logger().info("Show name: {} vs sanitized name: {}".format(show_name, sanitized_directory_name))
        directory_name = sanitized_directory_name if os.path.exists(sanitized_directory_name) else 'Unnamed'
        return self.recordings_directory + '/' + directory_name

    def _directory_for_show_and_episode(self, show_name, episode):
        from .master_import import safe_replace
        sanitized_episode_name = safe_replace(episode)
        return self._directory_for_show(show_name) + '/' + sanitized_episode_name

    def _ensure_directory_exists(self, directory):
        if directory is None:
            raise Exception, "Directory cannot be null"
        if not os.path.exists(directory):
            os.makedirs(directory)

    def _next_sequence_number_for(self, base_directory):
        entries = os.listdir(base_directory)
        numeric_entries = []
        largest_current_sequence_number = 0
        for entry in entries:
            numeric_entries.append(int(entry))
        if len(numeric_entries) > 0:
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
