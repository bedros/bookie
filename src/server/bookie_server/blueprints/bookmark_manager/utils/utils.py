from typing import Dict, Any


def filter_dict(dict_: Dict[Any, Any], *args):
    '''
    :param dict_:
    :param args: Keys to keep
    :return: Dictionary of the model instance with nulls filtered out.
    '''
    return {k: v for (k, v) in dict_.items() if (v or k in args)}
