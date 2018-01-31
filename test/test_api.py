from unittest import TestCase

from json import loads
import os

from bookie.app_factory import create_app
from bookie.blueprints.bookmark_manager.models import Bookmark, Tag
from bookie.extensions import db


class TestResourceBookmark(TestCase):
    endpoint_url = '/api/bookmark'

    @classmethod
    def setUpClass(cls):
        os.environ['BOOKIE_ENV'] = 'testing'
        os.environ['SQLALCHEMY_DATABASE_URI'] = 'sqlite://'

    def setUp(self):
        app = create_app()
        self.app = app.test_client()

        bookmarks = [Bookmark('foo', 'bar', notes='hello world'),
                     Bookmark('baz', 'buz')]

        with app.app_context():
            db.create_all(app=app)
            db.session.add_all(bookmarks)
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

    def test_put(self):
        bookmark_dict = dict(id=2, title='spam', url='ham', notes='spam ate the ham')

        raw_response = self.app.put(self.endpoint_url, data=bookmark_dict)
        self.assertEqual(raw_response.status_code, 200)

        raw_response = self.app.get(self.endpoint_url, data=dict(id=2))
        self.assertEqual(raw_response.status_code, 200)

        response = loads(raw_response.data.decode('utf8'))
        self.assertEqual(response['data']['id'], 2)
        self.assertEqual(response['data']['title'], 'spam')

    def test_put_invalid_id(self):
        bookmark_dict = dict(id=3, title='spam', url='ham', notes='spam ate the ham')
        raw_response = self.app.put(self.endpoint_url, data=bookmark_dict)
        self.assertEqual(raw_response.status_code, 404)

    def test_delete(self):
        raw_response = self.app.delete('/api/bookmark/', data=dict(id=2))
        self.assertEqual(raw_response.status_code, 410)

        raw_response = self.app.get('/api/bookmark/', data=dict(id=2))
        self.assertEqual(raw_response.status_code, 404)

    def test_delete_invalid_id(self):
        raw_response = self.app.delete('/api/bookmark/', data=dict(id=2))
        self.assertEqual(raw_response.status_code, 410)

        raw_response = self.app.get('/api/bookmark/', data=dict(id=2))
        self.assertEqual(raw_response.status_code, 404)


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
