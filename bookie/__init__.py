import os

from flask import Flask

from bookie import util
from bookie.config import Config
from bookie.data_manager import DataManager

################################################################################
VERSION = ('0.2.0-dev', 'reflexive rhea')
################################################################################


def create_app() -> Flask:
    instance_path = os.path.join(os.path.expanduser('~'), '.config/bookie')
    app = Flask(__name__, instance_path=instance_path,
                instance_relative_config=True)

    util.configure_flask_app(app)

    from .blueprints.bookmark_manager import bookmark_manager
    app.register_blueprint(bookmark_manager)

    return app


app = create_app()
data_manager = DataManager(app.config['DATABASE_URI'])
app.data_manager = data_manager
