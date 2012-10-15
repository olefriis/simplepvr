import logging

def logger():
    return PvrLogger()

class PvrLogger:
    logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)

    def __init__(self):
        self.logger = logging.getLogger('PvrLogger')

    def info(self, message):
        self.logger.info(message)

    def warn(self, message):
        self.logger.warning(message)

    def debug(self, message):
        self.logger.debug(message)

    def error(self, message):
        self.logger.error(message)