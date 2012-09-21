from sqlalchemy import Column
from sqlalchemy.orm import relationship, backref
from sqlalchemy.types import Integer, String, Text, DateTime, Boolean

from .master_import import db

class Channel(db.Model):
    __tablename__ = 'channels'

    id = db.Column(Integer, primary_key=True)
    name = db.Column(String, index=True)
    frequency = db.Column(Integer)
    channel_id = db.Column(Integer, index=True)
    hidden = db.Column(Boolean, nullable = False, default=False)

#    programmes = db.relationship("Programme", primaryjoin="Channel.id==Programme.channel_id", backref="channels")
#    has n, :programmes

    def __init__(self, name, frequency, channel_id, hidden=False):
        self.name = name
        self.frequency = frequency
        self.channel_id = channel_id
        self.hidden = hidden

    def add(self, name, frequency, channel_id, hidden=False):
        channel = Channel(name, frequency, channel_id, hidden)
        db.session.add(channel)
        db.session.flush()
        db.session.commit()
        return {id: channel.id}


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

    def with_name(self,name):
        result = Channel.query.filter(Channel.name == name).first()
        if not result:
            raise ValueError('Unknown channel: %s' % (str))

        return result

    def getId(self):
        return self.id

    def __repr__(self):
        return '<Channel name: %s, channel_id: %s, id: %s>' % (self.name, str(self.channel_id), str(self.id))


    @property
    def serialize(self):
        from .master_import import safe_value
        """Return object data in easily serializeable format"""
        return {
            'id'   : self.id,
            'name': safe_value(self.name)
            ,
            #'frequency'  : self.frequency,
            #'channel_id' : self.channel_id,
            'hidden': self.hidden
        }

