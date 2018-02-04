from logging import getLogger

from flask_restful import Resource
from sqlalchemy.orm.exc import NoResultFound
from webargs import fields
from webargs.flaskparser import use_kwargs

from ..common import utils
from ...models import Tag as TagModel


__all__ = ['Tag']

_logger = getLogger(__name__)


class Tag(Resource):
    _resource = 'tag'

    @use_kwargs({'id': fields.Int(missing=None)})
    def get(self, id):
        if id:
            try:
                tag = TagModel.query.filter_by(id=id).one()
                return utils.wrap_response(self._resource, tag.dump())

            except NoResultFound:
                _logger.error(f'No result found for Tag: id={id}')
                return utils.error_response('internal_error',
                                            f'No result for Tag: id={id}'),\
                       404

            except Exception:
                _logger.exception(f'Unhandled exception occurred getting Tag: id={id}')
                return utils.error_response('internal_error',
                                            f'Error occurred getting Tag: id={id}'), \
                       500

        else:
            try:
                tags = [t.dump() for t in TagModel.query.all()]
                return utils.wrap_response(self._resource, tags)

            except Exception:
                _logger.exception(f'Unhandled exception occurred getting Tag: all')
                return utils.error_response('interal_error',
                                            'Error occured getting Tag: all'), \
                       500
