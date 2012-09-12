from sqlalchemy import Column
from sqlalchemy.orm import sessionmaker, relationship, backref
from sqlalchemy.types import Integer, String, Text, DateTime, Boolean, Enum

from .master_import import db

class Schedule(db.Model):
    __tablename__ = 'schedules'

    id = db.Column(Integer, primary_key=True)
    title = db.Column(String(255))

    #TODO: type #Enum(VIDEO, AUDIO, AUDIO_DESC, CAPTIONS, name="type"), nullable=False
    type = db.Column(Enum('specification'), nullable=False)
    #    type, Enum[:specification]

    channel_id = db.Column(db.Integer, db.ForeignKey('channels.id'))
    channel = db.relationship('Channel', primaryjoin="Schedule.channel_id == Channel.id",
                              backref=db.backref('schedules', lazy='dynamic'))

#    belongs_to :channel, :required => false

    def __init__(self, title, type, channel):
        #from .master_import import Channel
        self.title = title
        self.type = type

        if channel is not None:
            self.channel_id = channel.id
            self.channel = channel#Channel.query.filter(Channel.id == channelId).first()

    @staticmethod
    def add_specification(title, channel=None):
        type = 'specification'
        schedule = Schedule(title, type, channel)
        db.session.add(schedule)
        db.session.flush()
        db.session.commit()
        return {'id': schedule.id }

    def __repr__(self):
        return '<Schedule id: %s, title: %s, channel_id: %s>' % (self.id, self.title, self.channel_id)

    @property
    def serialize(self):
        from .master_import import safe_value
        """Return object data in easily serializeable format"""
        return {
            'id'   : self.id,
            'title': safe_value(self.title),
            'channel'  : self.channel.serialize if self.channel is not None else None
        }
#    @property
#    def serialize_many2many(self):
#        """
#        Return object's relations in easily serializeable format.
#        NB! Calls many2many's serialize property.
#        """
#        return [ item.serialize for item in self.many2many]