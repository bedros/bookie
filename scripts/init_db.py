#!/usr/bin/env python

from bookie.data_manager import DataManager
from bookie.config import config


DataManager(config.database, True)