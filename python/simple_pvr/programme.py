from datetime import datetime, timedelta
from sqlalchemy import Column, MetaData
from sqlalchemy.schema import UniqueConstraint
from sqlalchemy.orm import sessionmaker, relationship, backref
from sqlalchemy.types import Integer, String, Text, DateTime, Boolean
from .master_import import Category
from .master_import import db

metadata = MetaData()

association_table = db.Table('programmes_categories',
                          db.Column('programme_id', Integer, db.ForeignKey('programmes.id')),
                          db.Column('category_id', Integer, db.ForeignKey('categories.id')),
                          UniqueConstraint('programme_id', 'category_id', name='uix_1')
)

class Programme(db.Model):
    __tablename__ = 'programmes'

    id = db.Column(Integer, primary_key=True)
    title = db.Column(String(255), index=True)
    subtitle = db.Column(String(255))
    description = db.Column(db.Text)
    series = db.Column(Boolean, nullable = False, default=False)
    start_time = db.Column(db.DateTime, index=True)
    stop_time = db.Column(db.DateTime, index=True)
    duration = db.Column(Integer)
    episode_num = db.Column(String(255), index=True)

    channel_id = db.Column(db.Integer, db.ForeignKey('channels.id'))
    channel = db.relationship('Channel', primaryjoin="Programme.channel_id == Channel.id",
                               backref=db.backref('programmes', lazy='dynamic'))

    categories = db.relationship('Category', secondary=association_table,
                           backref=db.backref('programmes', lazy='dynamic'))

    def __init__(self, channel, title, subtitle, description, start_time, stop_time, duration, episode_num=None, series=False, categories = []):
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.start_time = start_time
        self.stop_time = stop_time
        self.channel = channel
        self.duration = duration
        self.episode_num = episode_num
        self.series = series
        self.categories = self.mapToCategory(categories)
        #self.channel_id = channel.id

    def mapToCategory(self, listOfCategoryTexts):
        listOfCategoryTypes = []
        for category_name in listOfCategoryTexts:
            listOfCategoryTypes.append(Category.getByName(category_name))
        return listOfCategoryTypes

    @staticmethod
    def clear():
        Programme.query.delete()
        db.session.flush
        db.session.commit


    def add(self, commit=False):
        db.session.add(self)
        if commit:
            db.session.commit()

    @staticmethod
    def with_title(title):
        return Programme.query.\
            filter(Programme.start_time > datetime.now()).\
            filter(Programme.title == title).\
            order_by(Programme.start_time).\
            all()

    @staticmethod
    def on_channel_with_title(channel, title):
        return Programme.query.\
            filter(Programme.start_time > datetime.now()).\
            filter(Programme.title == title).\
            filter(Programme.channel==channel).\
            order_by(Programme.start_time).\
            all()

    @staticmethod
    def on_channel_with_title_and_start_time(channel, title, start_time):
        return Programme.query.\
            filter(Programme.channel == channel).\
            filter(Programme.title == title).\
            filter(Programme.start_time.between((start_time - timedelta(minutes=1)), (start_time + timedelta(minutes=1))))\
            .all()

    @staticmethod
    def titles_containing(text):
        return Programme.query.\
            filter(Programme.title.like('%' + text + '%')).\
            filter(Programme.start_time > datetime.now()).\
            order_by(Programme.title).\
            limit(8).all()

    @staticmethod
    def with_title_containing(text):
        return Programme.query.\
            filter(Programme.start_time > datetime.now()).\
            filter(Programme.title.like('%' + text + '%')).\
            order_by(Programme.start_time).\
            limit(20).all()

    @staticmethod
    def _current_programme_for(channel, now):
        from .master_import import json_friendly_tuple
        if not channel.hidden:
            #(Programme.id, Programme.title, Programme.startTime, Programme.duration)
            programme = db.session.query(Programme.id, Programme.title, Programme.start_time, Programme.duration).\
            filter(Programme.channel == channel).\
            filter(Programme.start_time <= now).\
            filter(Programme.stop_time > now).\
            first()
            return json_friendly_tuple(programme)

    @staticmethod
    def _upcoming_programmes_for(channel, limit, now):
        from .master_import import json_friendly_tuple
        if channel.hidden:
            return []
        else:
            results = db.session.query(Programme.id, Programme.title, Programme.start_time, Programme.duration).filter(Programme.channel == channel).filter(Programme.start_time > now).order_by(Programme.start_time).limit(limit).all()

            serialized_list = []
            for programme in results:
                serialized_list.append(json_friendly_tuple(programme))

            return serialized_list


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
            'start_time'  : self.start_time.isoformat(),
            'startTime'  : self.start_time.isoformat(),
            'stop_time'  : self.stop_time.isoformat(),
            'duration'  : self.duration,
            'channel'  : self.channel.serialize if self.channel is not None else None
        }

