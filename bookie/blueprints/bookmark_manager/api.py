# TODO: Document API using a doctool

import logging

import flask_restful
from flask import current_app
from webargs import fields
from webargs.flaskparser import use_kwargs

from bookie import models
from .app import bookmark_manager


logger = logging.getLogger(__name__)


class Api:
    _api_path = '/api/'

    def __init__(self, app):
        self.api = flask_restful.Api(app)
        self.setup_resources()

    def setup_resources(self):
        self.api.add_resource(Bookmarks,
                              self._api_path + 'bookmarks',
                              self._api_path + 'bookmarks/',
                              )


class Bookmarks(flask_restful.Resource):
    _resource = 'bookmarks'

    @use_kwargs({'id_': fields.Int(missing=None),
                 'title': fields.String(missing=None),
                 'url': fields.String(missing=None),
                 })
    def get(self, id_=None, title=None, url=None):
        if id_:
            try:
                bookmark = current_app.data_manager.get(models.Bookmark, id_).dump()
                return wrap_response(self, self._resource, bookmark)

            except LookupError as le:
                logger.exception('Unable to lookup bookmark with id {}'
                                 .format(id_))
                return wrap_response(self, self._resource, [])

        elif title:
            pass

        elif url:
            pass

        else:
            bookmarks = [b.dump() for b in current_app.data_manager.get_all(models.Bookmark)]
            return wrap_response(self, self._resource, bookmarks)

    @use_kwargs({'title': fields.String(required=True),
                 'url': fields.String(required=True),
                 'description': fields.String(missing=None),
                 })
    def post(self, title, url, description=None):
        bookmark = models.Bookmark(title=title,
                                   url=url,
                                   description=description,
                                   )
        id_ = current_app.data_manager.insert(bookmark)
        return wrap_response(self,
                             self._resource + " insert confirmation",
                             bookmark.dump()
                             )

    @use_kwargs({'id_': fields.Int(required=True),
                 'title': fields.String(missing=None),
                 'url': fields.String(missing=None),
                 'description': fields.String(missing=None),
                 })
    def put(self, id_, title, url, description):
        bookmark = models.Bookmark(title=title,
                                   url=url,
                                   description=description,
                                   )
        current_app.data_manager.update(bookmark, id_)
        return wrap_response(self,
                             self._resource + " update confirmation",
                             bookmark.dump(),
                             )

    @use_kwargs({'id_': fields.Int(required=True)})
    def delete(self, id_):
        current_app.data_manager.delete(models.Bookmark, id_)
        return wrap_response(self,
                             self._resource + " delete confirmation",
                             models.Bookmark(id_=id_).dump(),
                             )


def wrap_response(api, type_, data):
    """
    Wraps the response data in an object with some informative
    properties.
    
    :param api: An instance of ApiBase
    :param type_: Response type -- would normally just be the REST resource
    :param data: Response data
    :return: Response with informative properties
    """
    return {'type': type_,
            'data': data,
            }


def error_response(api, error_type, error_message):
    """
    Create a error response.
    :param api: An instance of ApiBase
    :param error_type: Error type (see "Valid Types")
    :param error_message: Messaging containing useful information about the
            error.
    :return: 
    
    # Valid Error Types
    - invalid_parameter
    - internal_error
    """
    return {'type': 'error',
            'error_type': error_type,
            'error_message': error_message,
            }


api = Api(bookmark_manager)
