from json import loads
import os
import sys
import urllib.parse as urlparse


class Config:
    def __init__(self, json_dict):
        self.port = self.try_parse_option(json_dict, 'port', 5000)
        self.database_provider = self.try_parse_option(json_dict,
                                                       'database_provider',
                                                       'sqlite')

        self.heroku = self.try_parse_option(json_dict, 'heroku', False)

        if self.database_provider == 'sqlite':
            if self.heroku:
                print('Can\'t use sqlite on Heroku. Exiting.')
                sys.exit(1)

            self.database_uri = self.try_parse_option(json_dict,
                                                      'database_uri',
                                                      'bookie.db')
            self.database = self.database_provider \
                            + ':///' \
                            + self.database_uri

        elif self.heroku:
            urlparse.uses_netloc.append("postgres")
            url = urlparse.urlparse(os.environ["DATABASE_URL"])

            self.database = self.database_provider \
                          + '://' \
                          + '{user}:{password}@{host}:{port}/{database}'\
                                .format(database = url.path[1:],
                                        user = url.username,
                                        password = url.password,
                                        host = url.hostname,
                                        port = url.port)

        else:
            print('Unknown database_provider')
            sys.exit(1)

        self.debug = self.try_parse_option(json_dict, 'debug', False)

    def try_parse_option(self, config, option, default):
        """
        Try to read an option, return default if KeyError.
        
        :param config: Dictionary of config options.
        :param option: Key of the option.
        :param default: Default value in case of KeyError.
        :return: option value or default value.
        """
        try:
            return config[option]
        except KeyError:
            # TODO: logging ('using default option')
            return default


try:
    with open('config.json', 'r') as f:
        config = Config(loads(f.read()))
except FileNotFoundError as fnfe:
    # TODO: log (config.json not found, using default config values)
    config = Config({})
