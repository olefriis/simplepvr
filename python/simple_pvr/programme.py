from datetime import datetime
from sqlalchemy import Column
from sqlalchemy.orm import sessionmaker, relationship, backref
from sqlalchemy.types import Integer, String, Text, DateTime, Boolean

from .master_import import db

class Programme(db.Model):
    __tablename__ = 'programmes'

    id = db.Column(Integer, primary_key=True)
    title = db.Column(String(255))
    subtitle = db.Column(String(255))
    description = db.Column(db.Text)
    startTime = db.Column(db.DateTime)
    duration = db.Column(Integer)

    channel_id = db.Column(db.Integer, db.ForeignKey('channels.id'))
    channel = db.relationship('Channel', primaryjoin="Programme.channel_id == Channel.id",
                               backref=db.backref('programmes', lazy='dynamic'))

    def __init__(self, channel, title, subtitle, description, start_time, duration):
        self.title = title
        self.subtitle = subtitle
#        if pub_date is None:
 #           pub_date = datetime.utcnow()
        self.description = description
        self.startTime = start_time
        self.duration = duration
        self.channel = channel
        #self.channel_id = channel.id

    def clear(self):
        Programme.query.all().delete()
        db.session.flush
        db.session.commit


    def add(self, commit=False):
        db.session.add(self)
        if commit:
            db.session.commit()

    @staticmethod
    def with_title(title):
        return Programme.query.\
            filter(Programme.title == title).\
            order_by(Programme.startTime).\
            all()

    @staticmethod
    def on_channel_with_title(channel, title):
        return Programme.query.\
            filter(Programme.title == title).\
            filter(Programme.channel==channel).\
            order_by(Programme.startTime).\
            all()

    @staticmethod
    def titles_containing(text):
        return Programme.query.\
            filter(Programme.title.like('%' + text + '%')).\
            order_by(Programme.title).\
            limit(8)

    @staticmethod
    def with_title_containing(text):
        return Programme.query.\
            filter(Programme.title.like('%' + text + '%')).\
            order_by(Programme.startTime).\
            limit(20)

    def __repr__(self):
        return '<Programme serialized: %s>' % (self.serialize)

    @property
    def serialize(self):
        from .master_import import safe_value
        """Return object data in easily serializeable format"""
        return {
            'id'   : self.id,
            'title': safe_value(self.title),
            'subtitle'  : safe_value(self.subtitle),
            'description'  : safe_value(self.description),
            'startTime'  : self.startTime,
            'duration'  : self.duration,
            'channel'  : self.channel.serialize if self.channel is not None else None
        }

    id = db.Column(Integer, primary_key=True)
    title = db.Column(String(255))
    subtitle = db.Column(String(255))
    description = db.Column(db.Text)
    startTime = db.Column(db.DateTime)
    duration = db.Column(Integer)

    channel_id = db.Column(db.Integer, db.ForeignKey('channels.id'))
    channel = db.relationship('Channel', primaryjoin="Programme.channel_id == Channel.id",
                              backref=db.backref('programmes', lazy='dynamic'))