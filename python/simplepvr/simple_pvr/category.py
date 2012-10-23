# -*- coding: <utf-8> -*-

from datetime import datetime
from sqlalchemy import Column, UniqueConstraint
from sqlalchemy.orm import sessionmaker, relationship, backref
from sqlalchemy.types import Integer, String, Text, DateTime, Boolean

from .master_import import db

cachedCategories = {}
class Category(db.Model):
    __tablename__ = 'categories'

    id = db.Column(Integer, primary_key=True)
    name = db.Column(String(255), index=True )

    __table_args__ = (
        UniqueConstraint("name"),
    )


    def __init__(self, name):
        self.name = name

    def add(self, commit=False):
        if not Category.getByName(self.name):
            db.session.add(self)
            if commit:
                db.session.commit()

    @staticmethod
    def getByName(name):
        global cachedCategories
        if cachedCategories.has_key(name):
            return cachedCategories[name]
        else:
            cat_obj = Category.query.filter(Category.name == name).first()
            if cat_obj:
                cachedCategories[name] = cat_obj
                print u"Added new element {0} to cache - new size {1}".format(cat_obj, len(cachedCategories))
                return cat_obj
            else:
                return None

    @staticmethod
    def with_name(name):
        return Category.query.\
        filter(Category.name == name).\
        first()

    def __repr__(self):
        return '<Category serialized: %s>' % (self.serialize)

    @property
    def serialize(self):
        from .master_import import safe_value
        """Return object data in easily serializeable format"""
        return {
            'id'   : self.id,
            'name': safe_value(self.name)
        }
