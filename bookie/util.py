# TODO Docuemnt environment variables

import logging
import os

from bookie.config import ProductionConfig, DevelopmentConfig, TestingConfig


def configure_flask_app(app):
    try:
        if os.environ['BOOKIE_ENV'] in ('prod', 'production'):
            config = ProductionConfig
        elif os.environ['BOOKIE_ENV'] in ('dev', 'development'):
            config = DevelopmentConfig
        elif os.environ['BOOKIE_ENV'] in ('test', 'testing'):
            config = TestingConfig
        else:
            config = ProductionConfig
    except KeyError:
        config = ProductionConfig

    # Default config
    app.config.from_object(config)

    logging_level = set_logging_level(app.debug)
    logging_format = '%(levelname)-8s  %(asctime)s  %(name)-20s  %(message)s'
    logging.basicConfig(level=logging_level, format=logging_format)

    logger = logging.getLogger(__name__)

    # Override value based on user config file
    try:
        # FIXME: Document
        # Should slient option be used here to avoid error?
        app.config.from_pyfile('config.py')
        logger.info('Loading config from file {}'.format('config.py'))
    except FileNotFoundError as e:
        # FIXME: Document
        logger.info('Using default config. Please see README.md')


def set_logging_level(is_debug: bool):
    if is_debug:
        return logging.DEBUG
    else:
        return logging.INFO
