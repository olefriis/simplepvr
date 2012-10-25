# -*- coding: <utf-8> -*-

import os, ConfigParser

config = ConfigParser.SafeConfigParser(allow_no_value=True)

config_dir=os.path.expanduser("~/.simplepvr")
env_var_conf_dir = 'CONFIG_DIR'
if os.environ.has_key(env_var_conf_dir):
    config_dir=os.path.abspath(os.environ[env_var_conf_dir])

if not os.path.exists(config_dir):
    os.makedirs(config_dir)

section_name_simplepvr = "SimplePVR"
section_name_logger = "Logger"
mandatory_key_recordings_path='recordings_path'

config_file = os.path.join(config_dir, 'simplepvr.ini')


def initialize_config_file(config, config_file, section_name_simplepvr):
    config.add_section(section_name_simplepvr)
    if os.environ.has_key('RECORDINGS_PATH'):
        config.set(section_name_simplepvr, mandatory_key_recordings_path, os.path.abspath(os.environ['RECORDINGS_PATH']))
    else:
        config.set(section_name_simplepvr, mandatory_key_recordings_path,
                   os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'recordings')))

    config.add_section(section_name_logger)
    config.set(section_name_logger, 'level', 'INFO')
    config.set(section_name_logger, 'file', 'simplepvr.log')
    # First run, writing our configuration file
    with open(config_file, 'wb') as configfile:
        config.write(configfile)


if os.path.exists(config_file) and os.path.isfile(config_file):
    print "Reading configuration from '{}'".format(config_file)
    config.read([config_file])
else:
    initialize_config_file(config, config_file, section_name_simplepvr)


def getOptionWithDefault(section_name, option_name, default=None):
    return config.get(section_name, option_name) if config.has_option(section_name, option_name) else default

def getSimplePvrOption(name, default=None):
    return getOptionWithDefault(section_name_simplepvr, name, default)

def getLoggerOption(name, default=None):
    return getOptionWithDefault(section_name_logger, name, default)

def getRecordingsPath():
    return getOptionWithDefault(mandatory_key_recordings_path)
