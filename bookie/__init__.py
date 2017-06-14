from flask import Flask

from bookie.config import config
from bookie.data_manager import DataManager


app = Flask(__name__)
dm = DataManager(config.database)

import bookie.views
