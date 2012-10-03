from .server import db

class DatabaseScheduleReader():

    def __init__(self):
        from .master_import import RecordingPlanner

        self._recording_planner = RecordingPlanner()

    def read(self):
        from .master_import import Schedule

        self._recording_planner._recordings = []
        for schedule in db.session.query(Schedule).all():
            self._recording_planner.specification(schedule.title, schedule.channel, schedule.start_time)
        
        self._recording_planner.finish()
