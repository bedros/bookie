import flask_restful
from webargs import fields
from webargs.flaskparser import use_kwargs

from bookie import app
from bookie import dm
from bookie import models


class Api:
    _api_path = '/api/'

    def __init__(self, app):
        self.api = flask_restful.Api(app)
        self.setup_resources()

    def setup_resources(self):
        self.api.add_resource( Bookmarks
                             , self._api_path + 'bookmarks'
                             , self._api_path + 'bookmarks/'
                             )


class Bookmarks(flask_restful.Resource):
    _resource = 'bookmarks'

    @use_kwargs({ 'id_': fields.Int(missing=None)
                , 'title': fields.String(missing=None)
                , 'url': fields.String(missing=None)
                })
    def get(self, id_=None, title=None, url=None):
        if id_:
            try:
                bookmark = dm.get(models.Bookmark, id_).dump()
                return wrap_response(self, self._resource, bookmark)

            except LookupError as le:
                # FIXME: Logging
                return wrap_response(self, self._resource, [])

        elif title:
            pass

        elif url:
            pass

        else:
            bookmarks = [b.dump() for b in dm.get_all(models.Bookmark)]
            return wrap_response(self, self._resource, bookmarks)

    @use_kwargs({ 'title': fields.String(required=True)
                , 'url': fields.String(required=True)
                , 'description': fields.String(missing=None)
                })
    def post(self, title, url, description=None):
        bookmark = models.Bookmark( title = title
                                  , url = url
                                  , description = description
                                  )
        id_ = dm.insert(bookmark)
        return wrap_response( self
                            , self._resource
                            , 'Inserted Bookmark with id {}'\
                                  .format(id_))

    @use_kwargs({ 'id_': fields.Int(required=True)
                , 'title': fields.String(missing=None)
                , 'url': fields.String(missing=None)
                , 'description': fields.String(missing=None)
                })
    def put(self, id_, title, url, description):
        bookmark = models.Bookmark( title = title
                                  , url = url
                                  , description = description
                                  )
        dm.update(bookmark, id_)
        return wrap_response( self
                            , self._resource
                            , 'Updated Bookmark with id {}'.format(id_))

    @use_kwargs({'id_': fields.Int(required=True)})
    def delete(self, id_):
        dm.delete(models.Bookmark, id_)
        return wrap_response( self
                            , self._resource
                            , 'Deleted Bookmark with id {}'.format(id_))


def wrap_response(api, type_, data):
    """
    Wraps the response data in an object with some informative
    properties.
    
    :param api: An instance of ApiBase
    :param type_: Response type -- would normally just be the REST resource
    :param data: Response data
    :return: Response with informative properties
    """
    return { 'type': type_
           , 'data': data
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
    return { 'type': 'error'
           , 'error_type': error_type
           , 'error_message': error_message
           }


api = Api(app)
