import datetime


class Recording:

    channel = None
    show_name = None
    start_time = None
    duration = None
    programme = None

    def __init__(self, channel, show_name, start_time, duration, programme):
        self.channel = channel
        self.show_name = show_name
        self.start_time = start_time
        self.duration = duration
        self.programme = programme

    def __str__(self):
        return "'{0}' from '{1}' at '{2}'".format(self.show_name, self.channel, self.start_time)

    def expired(self):
        return
        start_time + datetime.timedelta(seconds = duration) < datetime.now

    def inspect(self):
        return "'{0}' from '{1}' at '{2}'".format(self.show_name, self.channel, self.start_time)

