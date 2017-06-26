from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm.exc import NoResultFound

from bookie.models import Base


class DataManager:
    def __init__(self, database, create_db=False):
        self.database = database
        self.engine = create_engine(self.database)
        self.DBSession = sessionmaker(bind=self.engine)

        if create_db:
            Base.metadata.create_all(self.engine)
        else:
            Base.metadata.bind = self.engine

    def get(self, model, id_):
        session = self.DBSession()
        try:
            return session.query(model).filter(model.id_ == id_).one()
        except NoResultFound as nrf:
            raise LookupError('No {} with id {}.'.format(model.__name__, id_))

    def get_all(self, model):
        session = self.DBSession()
        return session.query(model).all()

    def update(self, model_inst, id_):
        session = self.DBSession()
        bookmark = session.query(type(model_inst)).filter_by(id_=id_).one()
        for (k,v) in self._to_dict(model_inst).items():
            setattr(bookmark, k, v)
        session.commit()

    def delete(self, model, id_):
        session = self.DBSession()
        session.query(model).filter_by(id_=id_).delete()
        session.commit()

    def insert(self, model):
        session = self.DBSession()
        session.add(model)
        session.commit()

    def _to_dict(self, model_inst):
        '''
        :param model_inst:
        :return: Dictionary of the model instance with nulls filterd out.
        '''
        return {k:v for (k,v) in model_inst.dump().items() if v}
