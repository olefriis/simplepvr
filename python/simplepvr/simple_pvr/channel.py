# -*- coding: <utf-8> -*-

from sqlalchemy import Column
from sqlalchemy.orm import relationship, backref
from sqlalchemy.types import Integer, String, Text, DateTime, Boolean

from .master_import import db

class Channel(db.Model):
    __tablename__ = 'channels'

    id = db.Column(Integer, primary_key=True)
    name = db.Column(String(255), index=True)
    frequency = db.Column(Integer)
    channel_id = db.Column(Integer, index=True)
    icon_url = db.Column(String(255))
    hidden = db.Column(Boolean, nullable = False, default=False)

#    programmes = db.relationship("Programme", primaryjoin="Channel.id==Programme.channel_id", backref="channels")
#    has n, :programmes

    def __init__(self, name, frequency, channel_id, icon_url=None,hidden=False):
        self.name = name
        self.frequency = frequency
        self.channel_id = channel_id
        self.icon_url = icon_url
        self.hidden = hidden

    def add(self, commit=False):
        db.session.add(self)
        if commit:
            db.session.commit()

    def save(self):
        db.session.flush()
        db.session.commit()

    @staticmethod
    def sorted_by_name():
        return Channel.query.\
            filter(Channel.hidden == 0).\
            order_by(Channel.name).all()

    def clear(self):
        from simple_pvr import Programme
        Programme.query.all().delete()
        Channel.query.all().delete()
        db.session.flush
        db.session.commit

    @staticmethod
    def with_current_programmes(id):
        from datetime import datetime

        channel = Channel.query.get(id)
        if not channel:
            return None
        return Channel._decorated_with_current_programmes(channel, datetime.now())

    @staticmethod
    def all_with_current_programmes():
        return map(Channel._decorated_with_current_programmes, Channel.query.order_by(Channel.name).all())

#    def clear(self):
#        Programme.

    @staticmethod
    def with_name(name):
        result = Channel.query.filter(Channel.name == name).first()
        if not result:
            raise ValueError('Unknown channel: %s' % (name))

        return result

    def getId(self):
        return self.id

    @staticmethod
    def _decorated_with_current_programmes(channel, now=None):
        from datetime import datetime
        from .master_import import Programme
        if now is None:
            now = datetime.now()

        current_programme = Programme._current_programme_for(channel, now)
        number_of_upcoming_programmes = 3 if current_programme else 4
        upcoming_programmes = Programme._upcoming_programmes_for(channel, number_of_upcoming_programmes, now)
        return {
            'channel': channel,
            'current_programme': current_programme,
            'upcoming_programmes': upcoming_programmes
        }

    def __repr__(self):
        return '<Channel name: %s, channel_id: %s, id: %s>' % (self.name, str(self.channel_id), str(self.id))


    @property
    def serialize(self):
        from .master_import import safe_value
        """Return object data in easily serializeable format"""
        return {
            'id'   : self.id,
            'name': safe_value(self.name),
            'icon_url': self.icon_url,
            #'frequency'  : self.frequency,
            #'channel_id' : self.channel_id,
            'hidden': self.hidden
        }

