from threading import Thread, Lock
import threading
import datetime

from .master_import import Recorder
from .pvr_logger import logger

def synchronized(lock):
    """ Synchronization decorator. """

    def wrap(f):
        def newFunction(*args, **kw):
            lock.acquire()
            try:
                return f(*args, **kw)
            finally:
                lock.release()
        return newFunction
    return wrap

myLock = Lock()
class Scheduler(threading.Thread):
    upcoming_recordings = []

    def __init__(self):
        
        self.scheduled_programmes = []
        Scheduler.upcoming_recordings = []
        self.current_recordings = [None, None]
        self.recorders = {}
        self.mutex = Lock()

    @synchronized(myLock)
    def run(self):
        #self.thread = Thread():
        while True:
            self.mutex.acquire()
            try:
                process(self)
                sleep(1)
            finally:
                self.mutex.release()

    @synchronized(myLock)
    def recordings(self,recordings):
        
        Scheduler.upcoming_recordings = sorted(recordings, key=lambda rec: rec.start_time)
        for upcoming in Scheduler.upcoming_recordings:
            if upcoming.expired:
               del(Scheduler.upcoming_recordings[Scheduler.upcoming_recordings.index(upcoming)])
#        Scheduler.upcoming_recordings = recordings.sort_by {|r| r.start_time }.find_all {|r| !r.expired? }
        logger().info("Scheduling upcoming recordings: {0}".format(Scheduler.upcoming_recordings))

        self.scheduled_programmes = self.programme_ids_from(Scheduler.upcoming_recordings)
        self.stop_current_recordings_not_relevant_anymore
        Scheduler.upcoming_recordings = self.remove_current_recordings(Scheduler.upcoming_recordings)
        if Scheduler.upcoming_recordings is None:
            Scheduler.upcoming_recordings = []

    def is_scheduled(self, programme):
        return programme.id in self.scheduled_programmes

    @synchronized(myLock)
    def status_text(self):
        if not self._is_recording():
            return 'Idle'

        count = 0
        status_texts = []
        for recording in self.current_recordings:
            if recording is not None:
                status_texts.append("Tuner {} is recording '{}' on channel '{}'".format(count, recording.show_name, recording.channel.name))
            count = count + 1

        if len(status_texts) > 0:
            return 'Recording ' + ", ".join(status_texts)
        else:
            return "Not recording"

    def get_upcoming_recordings(self):
        return Scheduler.upcoming_recordings

    def process(self):
        self.check_expiration_of_current_recordings
        self.check_start_of_coming_recordings

    def _is_recording(self):
        for recording in self.current_recordings:
            if recording is not None:
                return True
        return False

    # Does not do anything, refactor-error maybe
    #def _active_recordings(self):
    #    return self.current_recordings.find_all {|recording| recording }

    def programme_ids_from(self, recordings):
        result = {}
        for recording in recordings:
            if recording.programme:
                result[recording.programme.id] = True
        return result

    def remove_current_recordings(self, recordings):
        newUpcomingRecordings = []
        for recording in recordings:
            if recording not in self.current_recordings:
                newUpcomingRecordings.append(recording)
        return newUpcomingRecordings

    def stop_current_recordings_not_relevant_anymore(self):
        for recording in self.current_recordings:
            if recording and recording not in Scheduler.upcoming_recordings:
                stop_recording(recording)


    def check_expiration_of_current_recordings(self):
        for recording in self.current_recordings:
            if recording and recording.expired():
                stop_recording(recording)

    def check_start_of_coming_recordings(self):
        while should_start_next_recording:
            start_next_recording()

    def should_start_next_recording(self):
        if len(Scheduler.upcoming_recordings) > 0:
            next_recording = Scheduler.upcoming_recordings[0]
        return next_recording is not None and next_recording.start_time <= datetime.datetime.now()

    def stop_recording(self,recording):
        self.recorders[recording].stop
        self.recorders[recording] = None
        self.current_recordings[current_recordings.index(recording)] = None

    def start_next_recording(self):
        next_recording = Scheduler.upcoming_recordings.pop(0)
        available_slot = self.current_recordings.find_index(None)
        if available_slot:
            recorder = Recorder(available_slot, next_recording)
            self.current_recordings[available_slot] = next_recording
            self.recorders[next_recording] = recorder
            recorder.start()

