from unittest import TestCase

from dateutil.tz import tzutc

from bookie.blueprints.bookmark_manager.models import *
from bookie.blueprints.bookmark_manager.utils.datetime_utils import \
    parse_iso8601


class TestBookmark(TestCase):
    def setUp(self):
        self.bookmark = Bookmark('foo', 'bar')

    def test_bookmark_can_initialize_with_defaults(self):
        self.assertEqual(self.bookmark.title, 'foo')
        self.assertEqual(self.bookmark.url, 'bar')
        self.assertEqual(self.bookmark.notes, '')
        self.assertIsNotNone(self.bookmark.created)
        self.assertIsNotNone(self.bookmark.modified)
        self.assertEqual(len(self.bookmark.tags), 0)

    def test_bookmark_can_initialize_with_no_created_property(self):
        bookmark = Bookmark('foo', 'bar', created=None)
        self.assertIsNone(bookmark.created)

    def test_bookmark_can_be_assigned_a_tag(self):
        tag = Tag('qux')
        self.bookmark.tags.append(tag)
        self.assertIn(tag, self.bookmark.tags)
        self.assertIn(self.bookmark, tag.bookmarks)
