from datetime import datetime
import time


__all__ = ['datetime_dump', 'datetime_load']


def datetime_dump(self) -> int:
    return int(time.mktime(self.timetuple()))


def datetime_load(timestamp: int) -> datetime:
    return datetime.fromtimestamp(timestamp)
