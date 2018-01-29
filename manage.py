#!/bin/env python3

import click
from flask.helpers import get_debug_flag
from werkzeug import script

from bookie.app_factory import create_app
from bookie.extensions import db


@click.group()
def cli(): pass


@cli.command()
def run():
    app = create_app()
    db.create_all(app=app)
    app.run(port=app.config['PORT'], debug=get_debug_flag())


@cli.command()
def init():
    db.create_all(app=create_app())


@cli.command()
def shell():
    app = create_app()
    db.create_all(app=app)
    with app.app_context():
        from bookie.blueprints.bookmark_manager import models
        script.make_shell(lambda: {'models': models,
                                   'app': app,
                                   'db': db},
                          use_ipython=True)()


# @shell.command()
# @click.argument('database')
# def models(database):
#     from bookie.blueprints.bookmark_manager import models
#
#     engine = sa.create_engine(f'sqlite:///{database}')
#     sa.ext.declarative.declarative_base().metadata.create_all(engine)
#     session = sa.orm.sessionmaker(bind=engine)()
#
#     script.make_shell(lambda: {'models': models,
#                                'session': session},
#                       use_ipython=False)()


if __name__ == '__main__':
    cli()
