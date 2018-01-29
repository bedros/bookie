def wrap_response(type_, data):
    """
    Wraps the response data in an object with some informative
    properties.

    :param type_: Response type -- would normally just be the REST resource
    :param data: Response data
    :return: Response with informative properties
    """
    return {'type': type_,
            'data': data}


# XXX Unused
def error_response(error_type, error_message):
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
            'error_message': error_message}
