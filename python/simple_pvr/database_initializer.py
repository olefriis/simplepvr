from sqlalchemy import Column
from sqlalchemy.orm import sessionmaker, relationship, backref
from sqlalchemy.types import Integer, String, Text, DateTime, Boolean
#require 'active_support/time_with_zone'

import os

from .master_import import Schedule, Programme, Channel

class DatabaseInitializer():

#    id = db.Column(db.Integer, primary_key=True)
#    username = db.Column(db.String(80), unique=True)
#    email = db.Column(db.String(120), unique=True)

#    def __init__(self, username, email):
#        self.username = username
#        self.email = email



    def setup(self, database_file_name = None):
        if not database_file_name:
            database_file_name = os.pardir() + "/database.sqlite"

        #DataMapper.setup(:default, "sqlite://#{database_file_name}")
        #DataMapper.auto_upgrade!


    def clear(self):
        Schedule.query.all().delete()
        Programme.query.all().delete()
        Channel.query.all().delete()


 #   def prepare_for_test(self):
 #       if _initialized:
 #           return
 #       _database_file_name = Dir.pwd + '/spec/resources/test.sqlite'
 #       File.delete(_database_file_name) if File.exists?(_database_file_name)
 #       self.setup(_database_file_name)
 #       _initialized = true

##if os.path.exists(directory):
##    try:
##        os.remove(directory)
##    except:
##        print "Exception: ",str(sys.exc_info())
##else:
##print 'File not found at ',directory
