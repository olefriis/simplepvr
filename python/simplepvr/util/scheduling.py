import sys
import threading
import Queue
#import datetime
from datetime import datetime
import time

class Controller(threading.Thread):
    def __init__(self, queue):
        threading.Thread.__init__(self)
        self.queue = queue
        print self, " initialized"

    def run(self):
        print "Started"
        while True:
            #grabs host from queue
            task = self.queue.get()

            print "Thread {} handling {}".format(self.name, task())

            #signals to queue job is done
            self.queue.task_done()


class Task():
    def __init__(self, number):
        self.some_time = datetime.now()
        print "__init__", number

    def __call__(self):
        print "__call__"
        return "",5*5, " --> ", self

    def __repr__(self):
        return "<Task some_time: '{}' >".format(self.some_time)

queue = Queue.Queue()
start = time.time()
def main(argv=None):
    tasks = []
    for i in range(10):
        tasks.append(Task(i))

    #spawn a pool of threads, and pass them queue instance
    for i in range(2):
        t = Controller(queue)
        t.setDaemon(True)
        t.start()

        #populate queue with data
        for task in tasks:
            queue.put(task)

    #wait on the queue until everything has been processed
    queue.join()



if __name__ == "__main__":
    sys.exit(main())