from traceback import print_exc

import logging
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm.exc import NoResultFound

from bookie.i_data_manager import IDataManager
from bookie.models import Base


logger = logging.getLogger(__name__)


class DataManager(IDataManager):
    def __init__(self, database):
        logger.debug('Using database {}'.format(database))
        self.database = database
        self.engine = create_engine(self.database)
        self.DBSession = sessionmaker(bind=self.engine)
        self.session = None
        Base.metadata.create_all(self.engine)

    def get(self, model, id_):
        return self.with_session(self._get, [model, id_])

    def get_all(self, model):
        return self.with_session(self._get_all, [model])

    def insert(self, model_inst):
        return self.with_session(self._insert, [model_inst])

    def update(self, model_inst, id_):
        return self.with_session(self._update, [model_inst, id_])

    def delete(self, model, id_):
        return self.with_session(self._delete, [model, id_])

    def _get(self, model, id_):
        try:
            return self.session.query(model).filter(model.id_ == id_).one()
        except NoResultFound as nrf:
            raise LookupError('No {} with id {}.'.format(model.__name__, id_))

    def _get_all(self, model):
        return self.session.query(model).all()

    def _insert(self, model_inst):
        self.session.add(model_inst)
        self.session.commit()
        return model_inst.id_

    def _update(self, model_inst, id_):
        bookmark = self.session.query(type(model_inst))\
                               .filter_by(id_=id_).one()
        for (k,v) in self._to_dict(model_inst).items():
            setattr(bookmark, k, v)
        self.session.commit()

    def _delete(self, model, id_):
        self.session.query(model).filter_by(id_=id_).delete()
        self.session.commit()

    def _to_dict(self, model_inst):
        '''
        :param model_inst:
        :return: Dictionary of the model instance with nulls filtered out.
        '''
        return {k:v for (k,v) in model_inst.dump().items() if v}

    def with_session(self, func, args, args_method='*'):
        '''
        :param func: Function to execute with a session.
        :args: Arguments to pass to func.
        :args_method: Either * or ** (i.e. func(*args) or func(**args)).
        :return: Return value of func.
        '''
        try:
            self.session = self.DBSession()
            if args_method == '*':
                return func(*args)
            elif args_method == '**':
                return func(**args)
            else:
                raise TypeError('args_method needs to be either "*" or "**".')

        except LookupError as le:
            raise le

        except Exception as e:
            logging.exception('Exception occurred while executing a function '
                              'within a session')
            self.session.rollback()

        finally:
            self.session.close()
