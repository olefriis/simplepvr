# -*- coding: <utf-8> -*-

from sqlalchemy import Column
from sqlalchemy.orm import sessionmaker, relationship, backref
from sqlalchemy.types import Integer, String, Text, DateTime, Boolean, Enum

from .master_import import db

class Schedule(db.Model):
    __tablename__ = 'schedules'

    id = db.Column(Integer, primary_key=True)
    type = db.Column(Enum('specification', 'exception'), nullable=False)
    title = db.Column(String(255))
    start_time = db.Column(db.DateTime)
    stop_time = db.Column(db.DateTime)

    channel_id = db.Column(db.Integer, db.ForeignKey('channels.id'))
    channel = db.relationship('Channel', primaryjoin="Schedule.channel_id == Channel.id",
                              backref=db.backref('schedules', lazy='dynamic'))

#    belongs_to :channel, :required => false

    def __init__(self, title, type = 'specification', start_time=None, stop_time=None, channel=None):
        #from .master_import import Channel
        self.title = title
        self.type = type
        self.start_time = start_time
        self.stop_time = stop_time

        if channel is not None:
            self.channel_id = channel.id
            self.channel = channel#Channel.query.filter(Channel.id == channelId).first()

    def add(self, commit = False):
        db.session.add(self)
        if commit:
#            db.session.flush()
            db.session.commit()
        return {'id': self.id}

    @staticmethod
    def add_specification(title, start_time=None, stop_time=None, channel=None):
        type = 'specification'
        schedule = Schedule(title=title, type=type, start_time=start_time, stop_time=stop_time, channel=channel)
        db.session.add(schedule)
#        db.session.flush()
        db.session.commit()
        return {'id': schedule.id }

    def __repr__(self):
        from dateutil.tz import tzlocal
        start = self.start_time.replace(tzinfo=tzlocal()).isoformat() if self.start_time else ''
        stop = self.stop_time.replace(tzinfo=tzlocal()).isoformat() if self.start_time else ''
        return '<Schedule id: %s, title: %s, channel_id: %s, start: %s, stop: %s>' % (self.id, self.title, self.channel_id, start, stop)

    @property
    def serialize(self):
        from .master_import import safe_value
        from dateutil.tz import tzlocal
        """Return object data in easily serializeable format"""
        return {
            'id'   : self.id,
            'title': safe_value(self.title),
            'start_time': self.start_time.replace(tzinfo=tzlocal()).isoformat() if self.start_time is not None else None,
            'stop_time': self.stop_time.replace(tzinfo=tzlocal()).isoformat() if self.stop_time is not None else None,
            'is_exception': self.type == 'exception',
            'channel'  : self.channel.serialize if self.channel is not None else None
        }
