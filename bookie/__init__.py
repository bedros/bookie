import os

from flask import Flask

from bookie.config import config
from bookie.data_manager import DataManager


VERSION = ('0.1.0', 'timid tayra')


if config.heroku:
    create_db = False
else:
    create_db = True

app = Flask(__name__)
app.config['SERVER_NAME'] = 'localhost:{}'.format(config.port)
dm = DataManager(config.database, create_db)

import bookie.views
import bookie.routing.api
