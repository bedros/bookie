# TODO Error handling has a lot of repetition, it could be put into a helper
# function that returns an appropriate response based on type, msg and http code


from logging import getLogger
from typing import List, Set

from flask.helpers import get_debug_flag
from flask_restful import Resource
from sqlalchemy.exc import DBAPIError
from sqlalchemy.orm.exc import NoResultFound
from webargs import fields
from webargs.flaskparser import use_kwargs

from bookie.extensions import db
from ..common import utils
from ...models import Bookmark as BookmarkModel, Tag as TagModel
from ...utils.datetime_utils import parse_iso8601
from ...utils.utils import filter_dict


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
                 'tag_names': fields.List(fields.String(), missing=[])})
    def post(self, title, url, notes, tag_names):
        bookmark = BookmarkModel(title=title, url=url, notes=notes)

        if tag_names:
            try:
                tagInstances = self._process_and_get_tags_by_name(tag_names)
                bookmark.tags = tagInstances

            except Exception:
                _logger.exception(
                    'Unhandled exception occurred creating Bookmark, processing tags'
                )
                return utils.error_response('internal_error',
                                            'Failed to create Bookmark'), \
                       500

        try:
            db.session.add(bookmark)
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
                 'tag_names': fields.List(fields.String(), missing=[]),
                 'new_tag_names': fields.List(fields.String(), missing=[])})
    def put(self, id, title, url, notes, tag_names, new_tag_names):
        '''
        :param tag_names: Replace all tags with these
          Overrides new_tag_names if provided.
        :param new_tag_names: Append these tags
        '''
        try:
            new_bookmark = BookmarkModel(title=title,
                                         url=url,
                                         notes=notes,
                                         created=None).dump()
            new_bookmark['modified'] = parse_iso8601(new_bookmark['modified'])

            bookmark = self._get_by_id(id)

            for (k, v) in filter_dict(new_bookmark).items():
                _logger.debug(f'Updating bookmark.{k} to {v}')
                setattr(bookmark, k, v)

            if tag_names:
                tag_instances = self._process_and_get_tags_by_name(tag_names)
                bookmark.tags = tag_instances

            elif new_tag_names:
                tag_instances = self._process_and_get_tags_by_name(new_tag_names)
                unique_tags = list(set(bookmark.tags + tag_instances))
                bookmark.tags = unique_tags

            db.session.commit()

            if tag_names:
                # TODO It seems like modifications are not visible, so if a tag
                # was just made an orphan, it does not appear an orphan unless
                # the session is committed. Needs more investigation and
                # research into isolation levels if this methods of committing
                # twice before a significant overhead
                self._purge_orphan_tags()
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

            # TODO It seems like modifications are not visible, so if a tag was
            # just made an orphan, it does not appear an orphan unless the
            # session is committed. Needs more investigation and research into
            # isolation levels if this methods of committing twice before a
            # significant overhead
            self._purge_orphan_tags()
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
        :raises: NoResultFound
        '''
        return BookmarkModel.query.filter_by(id=id).one()

    def _process_and_get_tags_by_name(self, tag_names: List[str]) -> List[TagModel]:
        '''
        :raises: Exception -
          if creating new tags or inserting them into the database fails
        '''
        tag_instances = TagModel.query.filter(TagModel.name.in_(tag_names)).all()
        if len(tag_names) == len(tag_instances):
            return tag_instances

        existing_tags: Set[str] = set(map(lambda inst: inst.name, tag_instances))
        new_tags = set(tag_names) - existing_tags

        new_tag_instances = []
        for tag_name in new_tags:
            new_tag_instances.append(TagModel(tag_name))

        db.session.add_all(new_tag_instances)
        return tag_instances + new_tag_instances

    def _purge_orphan_tags(self):
        '''
        :raise: DBAPIError
        :raise: Exception
        '''
        try:
            if get_debug_flag():
                ids = db.session.execute('''
                    select id, name from tag where id not in (
                        select distinct tag_id from bookmark_and_bookmark_tag_association
                    )
                ''').fetchall()
                _logger.debug(f'Purging {len(ids)} orphan Tag entries: {ids}')
            else:
                _logger.debug(f'Purging orphan Tag entries')

            db.session.execute('''
            delete from tag where id not in (
              select distinct tag_id from bookmark_and_bookmark_tag_association
            )
            ''');

        except DBAPIError as error:
            _logger.exception('Error occurred purging orphan Tag entries')
            raise error
