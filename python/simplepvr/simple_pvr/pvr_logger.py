# -*- coding: <utf-8> -*-

import logging

_logger = None

def logger():
    global _logger
    if _logger:
        return _logger
    else:
        from .config import getLoggerOption
        logger_level = logging.getLevelName(logging.getLevelName(getLoggerOption("level", "info").upper()))
        logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logger_level, filename=getLoggerOption("file"))
        if getLoggerOption("file"):
            print "Logging to file '{0}' using level {1}".format(getLoggerOption("file"), logger_level)
        else:
            print "Logging to console using level {0}".format(logger_level)

        _logger = PvrLogger()
        return _logger

class PvrLogger:

    def __init__(self, file=None):
        self.logger = logging.getLogger('PvrLogger')

    def info(self, message):
        self.logger.info(message)

    def warn(self, message):
        self.logger.warning(message)

    def debug(self, message):
        self.logger.debug(message)

    def error(self, message):
        self.logger.error(message)