from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from bookie.models import Base


class DataManager:
    def __init__(self, database):
        self.database = database
        self.engine = create_engine(self.database)
        self.DBSession = sessionmaker(bind=self.engine)

        Base.metadata.bind = self.engine

    def _init_database(self):
        Base.metadata.create_all(self.engine)

    def get(self, model):
        session = self.DBSession()
        return session.query(model)

    def get_all(self, model):
        session = self.DBSession()
        return session.query(model).all()

    def delete(self):
        pass

    def insert(self, model):
        session = self.DBSession()

        session.add(model)
        session.commit()
