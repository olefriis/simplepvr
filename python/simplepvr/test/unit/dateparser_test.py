__author__ = 'frj'

import unittest, os
from dateutil.tz import tzlocal
from dateutil.parser import parse
from datetime import datetime, timedelta


class DateParserTestCase(unittest.TestCase):

    def test_no_offset_to_local(self):
        datestr_utc = "20121005170000 +0000"
        datestr_as_offset = "20121005190000 +0200"

        datestr__astimezone = parse(datestr_utc).astimezone(tz=tzlocal())
        datestr__astimezone_from_same_tz = parse(datestr_as_offset).astimezone(tz=tzlocal())

        self.assertEqual(datestr__astimezone, datestr__astimezone_from_same_tz)

        start = datetime.now() - timedelta(minutes = 15)
        now = datetime.now()
