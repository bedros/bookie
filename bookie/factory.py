import os
from flask import Flask

from bookie import util


def create_app() -> Flask:
    instance_path = os.path.join(os.path.expanduser('~'), '.config/bookie')
    app = Flask(__name__, instance_path=instance_path,
                 instance_relative_config=True)

    util.configure_flask_app(app)

    from .blueprints.bookmark_manager import bookmark_manager
    app.register_blueprint(bookmark_manager)

    return app
