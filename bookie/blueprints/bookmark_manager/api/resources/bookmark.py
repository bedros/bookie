# TODO Error handling has a lot of repetition, it could be put into a helper
# function that returns an appropriate response based on type, msg and http code


from logging import getLogger

from flask_restful import Resource
from sqlalchemy.orm.exc import NoResultFound
from webargs import fields
from webargs.flaskparser import use_kwargs

from bookie.extensions import db
from ..common import utils
from ...models import Bookmark as BookmarkModel

__all__ = ['Bookmark']

_logger = getLogger(__name__)


class Bookmark(Resource):
    _resource = 'bookmark'

    @use_kwargs({'id': fields.Int(missing=None)})
    def get(self, id):
        if id:
            try:
                bookmark = self._get_by_id(id).dump()
                return utils.wrap_response(self._resource, bookmark)

            except NoResultFound:
                _logger.error(f'No result found for Bookmark: id={id}')
                return utils.error_response('internal_error',
                                            f'No result for Bookmark: id={id}'), \
                       404

            except Exception:
                _logger.exception(
                    f'Unhandled exception occurred getting Bookmark: id={id}'
                )
                return utils.error_response(
                    'internal_error',
                    f'Error occurred getting Bookmark: id={id}'
                ), 500

        else:
            try:
                bookmarks = [b.dump() for b in BookmarkModel.query.all()]
                return utils.wrap_response(self._resource, bookmarks)

            except Exception:
                _logger.exception(
                    f'Unhandled exception occurred getting Bookmark: all'
                )
                return utils.error_response(
                    'internal_error',
                    f'Error occurred getting Bookmark: all'
                ), 500

    @use_kwargs({'title': fields.String(required=True),
                 'url': fields.String(required=True),
                 'notes': fields.String(missing=''),
                 'tags': fields.List(fields.String(), missing=[])})
    def post(self, title, url, notes, tags):
        # TODO tag handling
        bookmark = BookmarkModel(title=title, url=url, notes=notes)

        try:
            db.session.insert(bookmark)
            db.session.commit()
            return utils.wrap_response(self._resource, bookmark.dump()), 201

        except Exception:
            _logger.exception('Unhandled exception occurred creating Bookmark')
            return utils.error_response('internal_error', 'Failed to create Bookmark'), \
                   500

        finally:
            db.session.rollback()


    @use_kwargs({'id': fields.Int(required=True),
                 'title': fields.String(missing=None),
                 'url': fields.String(missing=None),
                 'notes': fields.String(missing=''),
                 'tags': fields.Nested(fields.String(), missing=[])})
    def put(self, id, title, url, notes):
        # TODO tag handling
        try:
            bookmark = BookmarkModel(title=title, url=url, notes=notes)
            db.session.commit()
            return utils.wrap_response(self._resource, bookmark.dump())

        except NoResultFound:
            _logger.error(f'Failed to update, no result found for Bookmark: id={id}')
            return utils.error_response(
                'internal_error',
                f'Failed to update, no result for Bookmark: id={id}'
            ), 404

        except Exception:
            _logger.exception(
                f'Unhandled exception occurred updating Bookmark: id={id}'
            )
            return utils.error_response('internal_error',
                                        f'Error occurred updating Bookmark: id={id}'), \
                   500

        finally:
            db.session.rollback()

    @use_kwargs({'id': fields.Int(required=True)})
    def delete(self, id):
        try:
            bookmark = self._get_by_id(id)
            db.session.delete(bookmark)
            db.session.commit()
            return utils.wrap_response(
                self._resource,
                f'Delete confirmation for Bookmark with id {id}'
            ), 410

        except NoResultFound:
            _logger.error(f'Failed to delete, no result found for Bookmark: id={id}')
            return utils.error_response(
                'internal_error',
                f'Failed to delete, no result found for Bookmark: id={id}'
            ), 404

        except Exception:
            _logger.exception(
                f'Unhandled exception occurred deleting Bookmark: id={id}'
            )
            return utils.error_response('internal_error',
                                        f'Error occurred deleting Bookmark: id={id}'), \
                   500

        finally:
            db.session.rollback()

    def _get_by_id(self, id) -> BookmarkModel:
        '''
        :param id:
        :return:
        :throws: NoResultFound
        '''
        return BookmarkModel.query.filter_by(id=id).one()
