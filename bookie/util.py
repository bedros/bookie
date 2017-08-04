# TODO Docuemnt environment variables

import os

from bookie.config import ProductionConfig, DevelopmentConfig


def configure_flask_app(app):
    if os.environ['BOOKIE_ENV'] in ('prod', 'production'):
        config = ProductionConfig
    elif os.environ['BOOKIE_ENV'] in ('dev', 'development'):
        config = DevelopmentConfig
    else:
        config = ProductionConfig

    # Default config
    app.config.from_object(config)

    # Override value based on user config file
    try:
        # FIXME: Document
        # Should slient option be used here to avoid error?
        app.config.from_pyfile('config.py')
        # app.config.from_pyfile(
        #         os.path.join(os.path.expanduser('~'), './config.py'))
    except FileNotFoundError as e:
        # FIXME: Logging
        # FIXME: Document
        print('Using default config. Please see README.md#Setup')
