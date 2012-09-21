import Queue
import bisect
import os
from threading import Thread, Lock
import threading
#import datetime
from datetime import datetime,timedelta
import time

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

class RecordingsQueue(Queue.Queue):
    "Thread-safe recordings queue, sorted by start_time"

    def _put(self, item):
        #sorted(self.queue, key=lambda rec: rec.start_time, reverse=False)
        # insert in order, note self.queue must be sorted for this to work
        bisect.insort(self.queue, item)

#
# try it

myLock = Lock()
recordings_queue = RecordingsQueue()
class Scheduler(threading.Thread):
    upcoming_recordings = []

    def __init__(self):
        self.scheduled_programmes = []
        Scheduler.upcoming_recordings = []
        self.current_recordings = [None, None]
        self.recorders = {}
        threading.Thread.__init__(self)

    def run(self):
        super(Scheduler, self).run()
        while True:
            self.process()
            time.sleep(10)


    @synchronized(myLock)
    def recordings(self,recordings):
        
        Scheduler.upcoming_recordings = sorted(recordings, key=lambda rec: rec.start_time)
        for upcoming in Scheduler.upcoming_recordings:
            if upcoming.expired():
               recordings_index = Scheduler.upcoming_recordings.index(upcoming)
               logger().info("Upcoming recording idx: {}".format(recordings_index))
               del(Scheduler.upcoming_recordings[recordings_index])
#        Scheduler.upcoming_recordings = recordings.sort_by {|r| r.start_time }.find_all {|r| !r.expired? }
        logger().info("Scheduling upcoming recordings: {0}".format(Scheduler.upcoming_recordings))

        self.scheduled_programmes = self.programme_ids_from(Scheduler.upcoming_recordings)
        self.stop_current_recordings_not_relevant_anymore()
        Scheduler.upcoming_recordings = self.remove_current_recordings(Scheduler.upcoming_recordings)

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

        return 'Recording ' + ", ".join(status_texts)

    def get_upcoming_recordings(self):
        return Scheduler.upcoming_recordings

    @synchronized(myLock)
    def process(self):
        logger().info("Scheduler '{}' doing processing of recordings queue".format(self.name))
        self.check_expiration_of_current_recordings()
        self.check_start_of_coming_recordings()

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
                self.stop_recording(recording)


    def check_expiration_of_current_recordings(self):
        for recording in self.current_recordings:
            if recording and recording.expired():
                self.stop_recording(recording)

    def check_start_of_coming_recordings(self):
        while self.should_start_next_recording():
            self.start_next_recording()

    def should_start_next_recording(self):
        next_recording = None
        if len(Scheduler.upcoming_recordings) > 0:
            next_recording = Scheduler.upcoming_recordings[0]
            if next_recording is not None:
                start_time = next_recording.start_time
                now = datetime.now()
                if start_time <= now and (start_time + timedelta(seconds = 60) > now):
                    return True
                elif start_time > now and (start_time - timedelta(seconds = 60)) <= now:
                    return True
                elif start_time < now:
                    logger().warn("Scheduled recording {} did not get recorded - tuners did not start in time".format(next_recording) )
                    del(Scheduler.upcoming_recordings[0]) ## upcoming recording expired

        return False


    def stop_recording(self,tuner):
        self.recorders[tuner].stop()
        self.recorders[tuner] = None
        self.current_recordings[current_recordings.index(tuner)] = None

    def start_next_recording(self):
        print "Start next recording"
        if len(Scheduler.upcoming_recordings) > 0:
            next_recording = Scheduler.upcoming_recordings.pop(0)
            print "Popped recording: {} from upcoming_recordings".format(type(next_recording))
            logger().info("Next recording {}".format(next_recording))

            if None in self.current_recordings:
                available_slot = self.current_recordings.index(None)
                recorder = Recorder(available_slot, next_recording)
                self.current_recordings[available_slot] = next_recording
                self.recorders[next_recording] = recorder
                recorder.start()

                ## TODO: fork here
#                r, w = os.pipe()
#                pid = os.fork()
#                if pid == 0:
#                    ## parent process
#                    os.close(w)
#                    r = os.fdopen(r) # turn r into a file object
#                else:
#                    os.close(r)
#                    w = os.fdopen(w, 'w') # turn w into writable file object
#                    ## child ~ recorder process



