import flask_restful

from bookie import app
from bookie import dm
from bookie import models


class Api:
    _api_path = '/api/'

    def __init__(self, app):
        self.api = flask_restful.Api(app)
        self.setup_resources()

    def setup_resources(self):
        self.api.add_resource(Bookmarks, self._api_path + 'bookmarks')


class Bookmarks(flask_restful.Resource):
    def get(self):
        bookmarks = [e.dump() for e in dm.get_all(models.Bookmark)]
        return wrap_response(self, 'bookmarks', bookmarks)


def wrap_response(api, type_, data):
    """
    Wraps the response data in an object with some informative
    properties.
    
    :param api: An instance of ApiBase
    :param type_: Response type -- would normally just be the REST resource
    :param data: Response data
    :return: Response with informative properties
    """
    return {
        'type': type_,
        'data': data,
    }


def error_response(api, error_type, error_message):
    """
    Create a error response.
    :param api: An instance of ApiBase
    :param error_type_: Error type (see "Valid Types")
    :param error_message: Messaging containing useful information about the
            error.
    :return: 
    
    # Valid Error Types
    - invalid_parameter
    - internal_error
    """
    return {
        'type': 'error',
        'error_type': error_type,
        'error_message': error_message,
    }


api = Api(app)
