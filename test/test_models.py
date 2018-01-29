from unittest import TestCase

from bookie.blueprints.bookmark_manager.models import *


class TestBookmark(TestCase):
    def setUp(self):
        self.bookmark = Bookmark('foo', 'bar')

    def testBookmarkCanInitializeWithDefaults(self):
        self.assertEqual(self.bookmark.title, 'foo')
        self.assertEqual(self.bookmark.url, 'bar')
        self.assertEqual(self.bookmark.notes, '')
        self.assertIsNotNone(self.bookmark.created)
        self.assertIsNotNone(self.bookmark.modified)
        self.assertEqual(len(self.bookmark.tags), 0)

    def testBookmarkCanBeAssignedATag(self):
        tag = Tag('qux')

        self.bookmark.tags.append(tag)

        self.assertIn(tag, self.bookmark.tags)
        self.assertIn(self.bookmark, tag.bookmarks)
