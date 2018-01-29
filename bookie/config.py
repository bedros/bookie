class Config(object):
    DEBUG = False
    TESTING = False
    SQLALCHEMY_DATABASE_URI = 'sqlite://'  # In memory database
    SQLALCHEMY_TRACK_MODIFICATIONS = False  # enabled by Flask SQLAlchemy
    PORT = 8888


class ProductionConfig(Config):
    pass


class DevelopmentConfig(Config):
    DEBUG = True


class TestingConfig(Config):
    TESTING = True
