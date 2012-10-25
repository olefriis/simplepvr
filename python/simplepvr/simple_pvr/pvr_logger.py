# -*- coding: <utf-8> -*-

import logging

def logger():
    from .config import getLoggerOption

    logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO, filename=getLoggerOption("file"))

    return PvrLogger()

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