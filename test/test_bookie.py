import os
from unittest import TestCase

from bookie import factory
from test.mock_data_manager import MockDataManager


class TestBookie(TestCase):
    def setUp(self):
        os.environ['BOOKIE_ENV'] = 'testing'
        self.app = factory.create_app().test_client()
        self.app.data_manager = MockDataManager()

    def testRouteIndex(self):
        response_html = '\n'.join(('<body>',
                                   '  <script>',
                                   '    app = Elm.Main.fullscreen();',
                                   '  </script>',
                                   '</body>'))
        rv = self.app.get('/')
        self.assertEqual(rv.status, '200 OK', 'Should have returned the index')
        self.assertTrue(bytes(response_html, 'utf-8') in rv.data)
