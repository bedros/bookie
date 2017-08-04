class Config(object):
    DEBUG = False
    TESTING = False
    DATABASE_URI = 'sqlite://'  # in memory database
    PORT = 8888


class ProductionConfig(Config):
    pass


class DevelopmentConfig(Config):
    DEBUG = True


class TestingConfig(Config):
    TESTING = True
