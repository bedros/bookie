from unittest import TestCase

from bookie.blueprints.bookmark_manager.utils.datetime_utils import \
    datetime_load, datetime_dump


class TestDateTime(TestCase):
    def testLoadingFromTimestamp(self):
        timestamp = 1234567890
        d = datetime_load(timestamp)
        self.assertEqual(d.ctime(), 'Fri Feb 13 18:31:30 2009')

    def testDumpingFromDateTime(self):
        timestamp = 1234567890
        d = datetime_load(timestamp)
        self.assertEqual(datetime_dump(d), timestamp)
