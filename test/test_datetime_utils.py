from datetime import datetime
from unittest import TestCase

import dateutil

from bookie.blueprints.bookmark_manager.utils.datetime_utils import \
    parse_iso8601


class TestDateTime(TestCase):
    def test_parsing_invalid_iso8601_string(self):
        timestamp = '2018-01-30T03:30:50.683843+'
        self.assertRaises(ValueError, parse_iso8601, timestamp)

    def test_parsing_iso8601_string_without_offset(self):
        timestamp = '2018-01-30T03:30:50.683843'
        self.assertRaises(ValueError, parse_iso8601, timestamp)

    def test_parsing_iso8601_string_with_non_utc_offset(self):
        timestamp = '2018-01-30T03:30:50.683843+11:00'
        date_time: datetime = parse_iso8601(timestamp)
        self.assertEqual(date_time.tzinfo.utcoffset(None).seconds, 0)
        self.assertEqual(date_time.ctime(),
                         date_time.astimezone(dateutil.tz.tzutc()).ctime())

    def test_parsing_iso8601_string_with_utc_offset(self):
        timestamp = '2018-01-30T03:30:50.683843+00:00'
        date_time: datetime = parse_iso8601(timestamp)
        self.assertEqual(date_time.tzinfo.utcoffset(None).seconds, 0)
