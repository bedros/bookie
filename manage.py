#!/bin/env python3

import click
from werkzeug import script
import sqlalchemy as sa


@click.group()
def cli():
    pass


@click.group()
def shell():
    pass


@click.command()
def datamanager():
    from bookie import app
    script.make_shell(lambda: {'data_manager': app.data_manager}, use_ipython=True)()


@click.command()
@click.argument('database')
def models(database):
    from bookie import models
    engine = sa.create_engine(f'sqlite:///{database}')
    sa.ext.declarative.declarative_base().metadata.create_all(engine)
    session = sa.orm.sessionmaker(bind=engine)()
    script.make_shell(
        lambda: {
            'models': models,
            'session': session,
        },
        use_ipython=True
        )()


shell.add_command(datamanager)
shell.add_command(models)

cli.add_command(shell)


if __name__ == '__main__':
    cli()
