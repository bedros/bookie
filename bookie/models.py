from sqlalchemy import ( Column
                       , ForeignKey
                       , Integer
                       , String
                       )
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship


Base = declarative_base()


class Bookmark(Base):
    __tablename__ = 'bookmark'

    bookmark_id = Column(Integer, primary_key=True)
    title = Column(String(512), nullable=False)
    url = Column(String(4096), nullable=False)
    description = Column(String(1024))


class BookmarkTag(Base):
    __tablename__ = 'bookmark_tag'

    bookmark_tag_id = Column(Integer, primary_key=True)
    tag = Column(String(64), nullable=False)
    bookmark_id = Column(Integer, ForeignKey('bookmark.bookmark_id'))
    bookmark = relationship(Bookmark)
