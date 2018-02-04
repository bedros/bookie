import dateutil
from datetime import datetime


__all__ = ['parse_iso8601']


def parse_iso8601(string: str) -> datetime:
    '''
    :param string:
    :return: datetime object with UTC timezone
    '''
    date_time: datetime = dateutil.parser.parse(string)

    if not date_time.tzinfo:
        raise ValueError('Invalid timezone')

    if date_time.tzinfo.utcoffset(None).seconds != 0:
        date_time = date_time.astimezone(dateutil.tz.tzutc())

    return date_time
