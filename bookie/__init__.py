import os

from flask import Flask

from bookie.config import config
from bookie.data_manager import DataManager


if 'CREATE_DB' in os.environ:
    create_db = True
else:
    create_db = False

app = Flask(__name__)
dm = DataManager(config.database, create_db)

import bookie.views
import bookie.routing.api
