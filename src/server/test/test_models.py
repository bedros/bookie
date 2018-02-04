from unittest import TestCase

from bookie_server.blueprints.bookmark_manager.models import *


class TestBookmark(TestCase):
    def setUp(self):
        self.bookmark = Bookmark('foo', 'bar')

    def test_bookmark_can_initialize_with_defaults(self):
        self.assertEqual(self.bookmark.title, 'foo')
        self.assertEqual(self.bookmark.url, 'bar')
        self.assertEqual(self.bookmark.notes, '')
        self.assertIsNotNone(self.bookmark._created)
        self.assertIsNotNone(self.bookmark.modified)
        self.assertEqual(len(self.bookmark.tags), 0)

    def test_bookmark_can_initialize_with_no_created_property(self):
        bookmark = Bookmark('foo', 'bar', created=None)
        self.assertIsNone(bookmark._created)

    def test_bookmark_can_be_assigned_a_tag(self):
        tag = Tag('qux')
        self.bookmark.tags.append(tag)
        self.assertIn(tag, self.bookmark.tags)
        self.assertIn(self.bookmark, tag.bookmarks)

    def test_bookmark_can_dump(self):
        bookmark_dict = self.bookmark.dump()
        self.assertEqual(bookmark_dict['title'], 'foo')
        self.assertEqual(bookmark_dict['url'], 'bar')
        self.assertEqual(bookmark_dict['notes'], '')
        self.assertEqual(len(bookmark_dict['tags']), 0)
        self.assertIsNotNone(bookmark_dict['created'])
        self.assertIsNotNone(bookmark_dict['modified'])
