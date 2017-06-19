from abc import (ABCMeta, abstractmethod)
import json
from sqlalchemy import ( Column
                       , ForeignKey
                       , Integer
                       , String
                       )
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship


Base = declarative_base()


class _JSONSeriallizable():
    def dumps(self):
        raise NotImplementedError('dumps not implemented in subclass '
                                  + self.__class__.__name__)


class Bookmark(Base, _JSONSeriallizable):
    __tablename__ = 'bookmark'

    bookmark_id = Column(Integer, primary_key=True)
    title = Column(String(512), nullable=False)
    url = Column(String(4096), nullable=False)
    description = Column(String(1024))

    def dump(self):
        dict_ = {
                    'bookmark_id': self.bookmark_id,
                    'title': self.title,
                    'url': self.url,
                    'description': self.description

                }
        return dict_


class BookmarkTag(Base, _JSONSeriallizable):
    __tablename__ = 'bookmark_tag'

    bookmark_tag_id = Column(Integer, primary_key=True)
    tag = Column(String(64), nullable=False)
    bookmark_id = Column(Integer, ForeignKey('bookmark.bookmark_id'))
    bookmark = relationship(Bookmark)

    def dump(self):
        dict_ = {
                    'bookmark_tag_id': self.bookmark_tag_id,
                    'tag': self.tag,
                    'bookmark_id': self.bookmark_id,
                }
        return dict_
