#!/bin/env python3

import click
import unittest
from flask.helpers import get_debug_flag
from werkzeug import script

from bookie_server.app_factory import create_app
from bookie_server.extensions import db


@click.group()
def cli(): pass


@cli.command()
def run():
    app = create_app()
    db.create_all(app=app)
    app.run(port=app.config['PORT'], debug=get_debug_flag())


@cli.command()
def test():
    loader = unittest.TestLoader()
    suite = loader.discover(start_dir='test')
    runner = unittest.TextTestRunner(verbosity=0)
    runner.run(suite)


@cli.command()
def init():
    db.create_all(app=create_app())


@cli.command()
def shell():
    app = create_app()
    db.create_all(app=app)
    with app.app_context():
        from bookie_server.blueprints.bookmark_manager import models
        script.make_shell(lambda: {'models': models,
                                   'app': app,
                                   'db': db},
                          use_ipython=True)()


if __name__ == '__main__':
    cli()
