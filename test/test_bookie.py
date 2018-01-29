import os
from unittest import TestCase

from bookie.app_factory import create_app


class TestBookie(TestCase):
    def setUp(self):
        os.environ['BOOKIE_ENV'] = 'testing'
        self.app = create_app().test_client()

    def testRouteIndex(self):
        response_html = '\n'.join(('<body>',
                                   '  <script>',
                                   '    app = Elm.Main.fullscreen();',
                                   '  </script>',
                                   '</body>'))
        rv = self.app.get('/')
        self.assertEqual(rv.status, '200 OK', 'Should have returned the index')
        self.assertTrue(bytes(response_html, 'utf-8') in rv.data)
