# TODO Docuemnt environment variables

import logging
import os

from flask import Flask

from . import extensions
from .blueprints.bookmark_manager import bookmark_manager_bp
from .config import ProductionConfig, DevelopmentConfig, TestingConfig


def create_app() -> Flask:
    instance_path = os.path.join(os.path.expanduser('~'), '.config/bookie')
    app = Flask(__name__,
                instance_path=instance_path,
                instance_relative_config=True)
    configure_flask_app(app)
    register_extensions(app)
    register_blueprints(app)

    return app


def register_extensions(app: Flask) -> None:
    extensions.db.init_app(app)


def register_blueprints(app: Flask) -> None:
    app.register_blueprint(bookmark_manager_bp)


def configure_flask_app(app) -> None:
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
