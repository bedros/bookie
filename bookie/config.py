from json import loads
import os
import sys
import urllib.parse as urlparse


class Config:
    def __init__(self, json_dict):
        self.database_provider = json_dict['database_provider']

        try:
            self.heroku = json_dict['heroku']
        except KeyError:
            self.heroku = False

        try:
            self.port = json_dict['port']
        except KeyError:
            self.port = 5000

        if self.database_provider == 'sqlite':
            self.database_uri = json_dict['database_uri']
            self.database = self.database_provider \
                            + ':///' \
                            + self.database_uri

        elif self.database_provider == 'postgresql+psycopg2':
            urlparse.uses_netloc.append("postgres")
            url = urlparse.urlparse(os.environ["DATABASE_URL"])

            self.database = self.database_provider \
                          + '://' \
                          + '{user}:{password}@{host}:{port}/{database}'.format(database = url.path[1:],
                                                                                user = url.username,
                                                                                password = url.password,
                                                                                host = url.hostname,
                                                                                port = url.port)

        else:
            print('Unknown database_provider')
            sys.exit(1)

        self.debug = json_dict['debug'] == "true" if 'debug' in json_dict \
                                                  else False


with open('config.json', 'r') as f:
    config = Config(loads(f.read()))
