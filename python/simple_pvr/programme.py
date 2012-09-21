from datetime import datetime
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
    startTime = db.Column(db.DateTime)
    duration = db.Column(Integer)

    channel_id = db.Column(db.Integer, db.ForeignKey('channels.id'))
    channel = db.relationship('Channel', primaryjoin="Programme.channel_id == Channel.id",
                               backref=db.backref('programmes', lazy='dynamic'))

    categories = db.relationship('Category', secondary=association_table,
                           backref=db.backref('programmes', lazy='dynamic'))

    def __init__(self, channel, title, subtitle, description, start_time, duration, series=False, categories = []):
        self.title = title
        self.subtitle = subtitle
#        if pub_date is None:
 #           pub_date = datetime.utcnow()
        self.description = description
        self.startTime = start_time
        self.duration = duration
        self.channel = channel
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
            filter(Programme.startTime > datetime.now()).\
            filter(Programme.title == title).\
            order_by(Programme.startTime).\
            all()

    @staticmethod
    def on_channel_with_title(channel, title):
        return Programme.query.\
            filter(Programme.startTime > datetime.now()).\
            filter(Programme.title == title).\
            filter(Programme.channel==channel).\
            order_by(Programme.startTime).\
            all()

    @staticmethod
    def titles_containing(text):
        return Programme.query.\
            filter(Programme.title.like('%' + text + '%')).\
            filter(Programme.startTime > datetime.now()).\
            order_by(Programme.title).\
            limit(8)

    @staticmethod
    def with_title_containing(text):
        return Programme.query.\
            filter(Programme.startTime > datetime.now()).\
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