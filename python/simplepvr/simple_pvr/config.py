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
mandatory_key_hdhomerun_config_path='hdhomerun_config_path'

config_file = os.path.join(config_dir, 'simplepvr.ini')


def initialize_config_file(config, config_file, section_name_simplepvr):
    config.add_section(section_name_simplepvr)
    if os.environ.has_key('RECORDINGS_PATH'):
        config.set(section_name_simplepvr, mandatory_key_recordings_path, os.path.abspath(os.environ['RECORDINGS_PATH']))
    else:
        config.set(section_name_simplepvr, mandatory_key_recordings_path,
                   os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'recordings')))

    if os.environ.has_key('HDHOMERUN_CONFIG_PATH'):
        config.set(section_name_simplepvr, mandatory_key_hdhomerun_config_path, os.path.abspath(os.environ['HDHOMERUN_CONFIG_PATH']))
    else:
        config.set(section_name_simplepvr, mandatory_key_hdhomerun_config_path,
                   _findHdhomerunConfig())

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

def _findHdhomerunConfig():
    # Look for hdhomerun_config in path:
    executable_on_path = which('hdhomerun_config')
    if executable_on_path:
        return executable_on_path[0]
    else:
        return os.path.abspath(os.path.join(config_dir, 'hdhomerun_config'))
        
    

def getOptionWithDefault(section_name, option_name, default=None):
    return config.get(section_name, option_name) if config.has_option(section_name, option_name) else default

def getSimplePvrOption(name, default=None):
    return getOptionWithDefault(section_name_simplepvr, name, default)

def getSimplePvrInt(name, default=0):
    return config.getint(section_name_simplepvr, name) if config.has_option(section_name_simplepvr, name) else default

def getLoggerOption(name, default=None):
    return getOptionWithDefault(section_name_logger, name, default)

def getRecordingsPath():
    return getOptionWithDefault(section_name_simplepvr, mandatory_key_recordings_path)

def getHdhomerunConfigPath():
    hdhrpath = getHdhomerunConfigPathFromConfig()
    if not hdhrpath:
        hdhrpath = _findHdhomerunConfig()
        
    if os.path.isfile(hdhrpath):
        return hdhrpath
    else:
        raise Exception("Unable to find hdhomerun_config in location {0}".format(hdhrpath))

def getHdhomerunConfigPathFromConfig():
    return getOptionWithDefault(section_name_simplepvr, mandatory_key_hdhomerun_config_path)

def df_h(path=getRecordingsPath()):
    s = os.statvfs(path)
    df = (s.f_bavail * s.f_frsize)
    return bytes2human(df)

def bytes2human(n):
    # http://code.activestate.com/recipes/578019
    # >>> bytes2human(10000)
    # '9.8K'
    # >>> bytes2human(100001221)
    # '95.4M'
    symbols = ('K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y')
    prefix = {}
    for i, s in enumerate(symbols):
        prefix[s] = 1 << (i+1)*10
    for s in reversed(symbols):
        if n >= prefix[s]:
            value = float(n) / prefix[s]
            return '%.1f%s' % (value, s)
    return "%sB" % n
    
def which(name, flags=os.X_OK):
    result = []
    exts = filter(None, os.environ.get('PATHEXT', '').split(os.pathsep))
    path = os.environ.get('PATH', None)
    if path is None:
        return []
    for p in os.environ.get('PATH', '').split(os.pathsep):
        p = os.path.join(p, name)
        if os.access(p, flags):
            result.append(p)
        for e in exts:
            pext = p + e
            if os.access(pext, flags):
                result.append(pext)
    return result