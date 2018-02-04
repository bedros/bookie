import os
from json import loads
from typing import Any, Dict
from unittest import TestCase

from bookie_server.app_factory import create_app
from bookie_server.blueprints.bookmark_manager.models import Bookmark, Tag
from bookie_server.extensions import db


class TestResourceBookmark(TestCase):
    endpoint_url = '/api/bookmark'

    @classmethod
    def setUpClass(cls):
        os.environ['BOOKIE_ENV'] = 'testing'
        os.environ['SQLALCHEMY_DATABASE_URI'] = 'sqlite://'

    def setUp(self):
        self.real_app = create_app()
        self.app = self.real_app.test_client()

        tags = [Tag('stuff', id=1), Tag('other-stuff', id=2)]
        bookmarks = [Bookmark('foo', 'bar', id=1,
                              notes='hello world',
                              tags=[tags[0]]),
                     Bookmark('baz', 'buz', id=2, tags=tags)]

        with self.real_app.app_context():
            db.create_all(app=self.real_app)
            db.session.add_all(bookmarks)
            db.session.add_all(tags)
            db.session.commit()

    def test_get_all(self):
        raw_response = self.app.get(self.endpoint_url)
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))

        bookmark1_dict = response['data'][0]
        bookmark2_dict = response['data'][1]

        self.assertEqual(response['type'], 'bookmark')
        self.assertEqual(type(response['data']), list)

        self.assertIsNotNone(bookmark1_dict['id'])
        self.assertEqual(bookmark1_dict['title'], 'foo')
        self.assertEqual(bookmark1_dict['url'], 'bar')
        self.assertEqual(bookmark1_dict['notes'], 'hello world')
        self.assertIsNotNone(bookmark1_dict['created'])
        self.assertIsNotNone(bookmark1_dict['modified'])

        self.assertIsNotNone(bookmark2_dict['id'])
        self.assertEqual(bookmark2_dict['title'], 'baz')
        self.assertEqual(bookmark2_dict['url'], 'buz')
        self.assertEqual(bookmark2_dict['notes'], '')
        self.assertIsNotNone(bookmark2_dict['created'])
        self.assertIsNotNone(bookmark2_dict['modified'])

        self.assertNotEqual(bookmark1_dict['id'], bookmark2_dict['id'])

    def test_get_by_id(self):
        raw_response = self.app.get(self.endpoint_url, data=dict(id=2))
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))

        bookmark = response['data']

        self.assertEqual(bookmark['id'], 2)
        self.assertEqual(bookmark['title'], 'baz')
        self.assertEqual(bookmark['url'], 'buz')
        self.assertEqual(bookmark['notes'], '')
        self.assertIsNotNone(bookmark['created'])
        self.assertIsNotNone(bookmark['modified'])
        self.assertIn(bookmark['tags'][0]['name'], ('stuff', 'other-stuff'))
        self.assertIn(bookmark['tags'][1]['name'], ('stuff', 'other-stuff'))

    def test_get_by_id_invalid_id(self):
        raw_response = self.app.get(self.endpoint_url, data=dict(id=3))
        self.assertEqual(raw_response.status_code, 404)

    def test_post(self):
        bookmark_dict = dict(title='spam', url='ham', notes='spam ate the ham')

        raw_response = self.app.post(self.endpoint_url, data=bookmark_dict)
        self.assertEqual(raw_response.status_code, 201)

        response = loads(raw_response.data.decode('utf8'))
        self.assertIsNotNone(response['data']['id'])
        id = response['data']['id']

        raw_response = self.app.get(self.endpoint_url, data=dict(id=id))
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))

        bookmark = response['data']

        self.assertEqual(bookmark['id'], id)
        self.assertEqual(bookmark['title'], 'spam')
        self.assertEqual(bookmark['url'], 'ham')
        self.assertEqual(bookmark['notes'], 'spam ate the ham')
        self.assertIsNotNone(bookmark['created'])
        self.assertIsNotNone(bookmark['modified'])

    def test_post_with_existing_tags(self):
        bookmark_dict = dict(title='spam',
                             url='ham',
                             notes='spam ate the ham',
                             tag_names=['stuff', 'other-stuff'])

        raw_response = self.app.post(self.endpoint_url, data=bookmark_dict)
        self.assertEqual(raw_response.status_code, 201)
        response = loads(raw_response.data.decode('utf8'))
        id = response['data']['id']

        raw_response = self.app.get(self.endpoint_url, data=dict(id=id))
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))
        bookmark = response['data']

        self.assertEqual(len(bookmark['tags']), 2)
        self.assertIn(bookmark['tags'][0]['name'], ['stuff', 'other-stuff'])
        self.assertIn(bookmark['tags'][1]['name'], ['stuff', 'other-stuff'])

    def test_post_with_existing_and_new_tags(self):
        bookmark_dict = dict(title='spam',
                             url='ham',
                             notes='spam ate the ham',
                             tag_names=['stuff', 'more-stuff'])

        raw_response = self.app.post(self.endpoint_url, data=bookmark_dict)
        self.assertEqual(raw_response.status_code, 201)
        response = loads(raw_response.data.decode('utf8'))
        id = response['data']['id']

        raw_response = self.app.get(self.endpoint_url, data=dict(id=id))
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))
        bookmark = response['data']

        self.assertEqual(len(bookmark['tags']), 2)
        self.assertIn(bookmark['tags'][0]['name'], ['stuff', 'more-stuff'])

        raw_response = self.app.get(self.endpoint_url)
        response = loads(raw_response.data.decode('utf8'))

        self.assertEqual(len(response['data']), 3)

    def test_put(self):
        bookmark_dict = dict(id=2, title='spam', url='ham')

        raw_response = self.app.put(self.endpoint_url, data=bookmark_dict)
        self.assertEqual(raw_response.status_code, 200)

        raw_response = self.app.get(self.endpoint_url, data=dict(id=2))
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))
        self.assertEqual(response['data']['id'], 2)
        self.assertEqual(response['data']['title'], 'spam')

    def test_put_invalid_id(self):
        bookmark_dict = dict(id=3, title='', url='')
        raw_response = self.app.put(self.endpoint_url, data=bookmark_dict)
        self.assertEqual(raw_response.status_code, 404)

    def test_put_replace_tags_with_existing_tags(self):
        bookmark_dict = dict(id=2, title='spam', url='ham', tag_names=['other-stuff'])

        raw_response = self.app.put(self.endpoint_url, data=bookmark_dict)
        self.assertEqual(raw_response.status_code, 200)

        raw_response = self.app.get(self.endpoint_url, data=dict(id=2))
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))
        self.assertEqual(len(response['data']['tags']), 1)
        self.assertEqual(response['data']['tags'][0]['name'], 'other-stuff')

        self.assert_number_of_tags_in_database(2)

    def test_put_replace_tags_with_existing_and_new_tags(self):
        bookmark_dict = dict(id=2,
                             title='spam',
                             url='ham',
                             tag_names=['other-stuff', 'more-stuff'])

        raw_response = self.app.put(self.endpoint_url, data=bookmark_dict)
        self.assertEqual(raw_response.status_code, 200)

        raw_response = self.app.get(self.endpoint_url, data=dict(id=2))
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))
        self.assertEqual(len(response['data']['tags']), 2)
        self.assertIn(response['data']['tags'][0]['name'],
                      ['other-stuff', 'more-stuff'])
        self.assertIn(response['data']['tags'][1]['name'],
                      ['other-stuff', 'more-stuff'])

        self.assert_number_of_tags_in_database(3)

    def test_put_adding_existing_tags(self):
        bookmark_dict = dict(id=1,
                             title='spam',
                             url='ham',
                             new_tag_names=['other-stuff'])

        raw_response = self.app.put(self.endpoint_url, data=bookmark_dict)
        self.assertEqual(raw_response.status_code, 200)

        raw_response = self.app.get(self.endpoint_url, data=dict(id=1))
        self.assertEqual(raw_response.status_code, 200)

        expected_tags = ['stuff', 'other-stuff']
        response = loads(raw_response.data.decode('utf8'))
        self.assertEqual(len(response['data']['tags']), 2)
        self.assertIn(response['data']['tags'][0]['name'], expected_tags)
        self.assertIn(response['data']['tags'][1]['name'], expected_tags)

        self.assert_number_of_tags_in_database(2)

    def test_put_adding_existing_and_new_tags(self):
        bookmark_dict = dict(id=1,
                             title='spam',
                             url='ham',
                             new_tag_names=['other-stuff', 'more-stuff'])

        raw_response = self.app.put(self.endpoint_url, data=bookmark_dict)
        self.assertEqual(raw_response.status_code, 200)

        raw_response = self.app.get(self.endpoint_url, data=dict(id=1))
        self.assertEqual(raw_response.status_code, 200)

        expected_tags = ['stuff', 'other-stuff', 'more-stuff']
        response = loads(raw_response.data.decode('utf8'))
        self.assertEqual(len(response['data']['tags']), 3)
        self.assertIn(response['data']['tags'][0]['name'], expected_tags)
        self.assertIn(response['data']['tags'][1]['name'], expected_tags)
        self.assertIn(response['data']['tags'][2]['name'], expected_tags)

        self.assert_number_of_tags_in_database(3)

    def test_delete(self):
        raw_response = self.app.delete(self.endpoint_url, data=dict(id=2))
        self.assertEqual(raw_response.status_code, 410)

        raw_response = self.app.get(self.endpoint_url, data=dict(id=2))
        self.assertEqual(raw_response.status_code, 404)

    def test_delete_invalid_id(self):
        raw_response = self.app.delete(self.endpoint_url, data=dict(id=2))
        self.assertEqual(raw_response.status_code, 410)

        raw_response = self.app.get(self.endpoint_url, data=dict(id=2))
        self.assertEqual(raw_response.status_code, 404)

    def test_delete_cleans_up_orphan_tags(self):
        raw_response = self.app.delete(self.endpoint_url, data=dict(id=2))
        self.assertEqual(raw_response.status_code, 410)

        tags = self.assert_number_of_tags_in_database(1)
        self.assertEqual(tags[0]['id'], 1)

    def assert_number_of_tags_in_database(self, length) -> Dict[str, Any]:
        raw_response = self.app.get('/api/tag/')
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))
        tags = response['data']

        self.assertEqual(len(tags), length)

        return tags


class TestResourceTag(TestCase):
    endpoint_url = '/api/tag'

    @classmethod
    def setUpClass(cls):
        os.environ['BOOKIE_ENV'] = 'testing'
        os.environ['SQLALCHEMY_DATABASE_URI'] = 'sqlite://'

    def setUp(self):

        app = create_app()
        self.app = app.test_client()

        tags = [Tag('foo'), Tag('bar')]

        with app.app_context():
            db.create_all(app=app)
            db.session.add_all(tags)
            db.session.commit()

    def test_get_all(self):
        raw_response = self.app.get(self.endpoint_url)
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))

        tag1_dict = response['data'][0]
        tag2_dict = response['data'][1]

        self.assertIsNotNone(tag1_dict['id'])
        self.assertEqual(tag1_dict['name'], 'foo')

        self.assertIsNotNone(tag2_dict['id'])
        self.assertEqual(tag2_dict['name'], 'bar')

        self.assertNotEqual(tag1_dict['id'], tag2_dict['id'])

    def test_get_by_id(self):
        raw_response = self.app.get(self.endpoint_url, data=dict(id=2))
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))

        tag = response['data']

        self.assertEqual(tag['id'], 2)
        self.assertEqual(tag['name'], 'bar')

    def test_get_by_id_invalid_id(self):
        raw_response = self.app.get(self.endpoint_url, data=dict(id=3))
        self.assertEqual(raw_response.status_code, 404)
