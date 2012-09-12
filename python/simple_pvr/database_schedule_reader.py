##require File.dirname(__FILE__) + '/pvr_initializer'
##require File.dirname(__FILE__) + '/model/database_initializer'
##require File.dirname(__FILE__) + '/recording_planner'

from sqlalchemy.orm import sessionmaker
from .server import db

class DatabaseScheduleReader():

    def __init__(self):
        from .master_import import RecordingPlanner

        self._recording_planner = RecordingPlanner()

    def read(self):
        from .master_import import Schedule

        for schedule in db.session.query(Schedule).all():
            self._recording_planner.specification(schedule.title, schedule.channel)
        
        self._recording_planner.finish()
