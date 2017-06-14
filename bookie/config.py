from json import loads


class Config:
    def __init__(self, json_dict):
        self.database_provider = json_dict['database_provider']
        self.database_uri = json_dict['database_uri']
        self.database = self.database_provider \
                      + ':///' \
                      + self.database_uri

        self.debug = json_dict['debug'] == "true" if 'debug' in json_dict \
                                                  else False


with open('config.json', 'r') as f:
    config = Config(loads(f.read()))
