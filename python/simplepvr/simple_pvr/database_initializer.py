# -*- coding: <utf-8> -*-

from sqlalchemy import Column
from sqlalchemy.orm import sessionmaker, relationship, backref
from sqlalchemy.types import Integer, String, Text, DateTime, Boolean
#require 'active_support/time_with_zone'

import os

from .master_import import Schedule, Programme, Channel, Category, db


class DatabaseInitializer():

    def setup(self, database_file_name = None):
        if not database_file_name:
            db.create_all()


    def clear(self):
        Schedule.query.delete()
        Programme.query.delete()
        Channel.query.delete()
        Category.query.delete()
