'''
Application models
'''

from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, Text, Table
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

from .util import truncate_str


Base = declarative_base()


class _JSONSeriallizable():
    def dump(self):
        raise NotImplementedError(
            f'dumps not implemented in subclass {self.__class__.__name__}'
        )


bookmark_and_bookmark_tag_association_table = Table(
    'bookmark_and_bookmark_tag_association',
    Base.metadata,
    Column('bookmark_id', Integer, ForeignKey('bookmark.id_')),
    Column('bookmark_tag_id', Integer, ForeignKey('bookmark_tag.id_'))
)


class Bookmark(Base, _JSONSeriallizable):
    __tablename__ = 'bookmark'

    id_ = Column(Integer, primary_key=True)
    title = Column(Text, nullable=False)
    url = Column(Text, nullable=False)
    notes = Column(Text, nullable=False)
    modified = Column(DateTime, nullable=False)
    created = Column(DateTime, nullable=False)

    def __init__(self,
                 title,
                 url,
                 notes='',
                 modified=datetime.now(),
                 created=datetime.now()):
        self.title = title
        self.url = url
        self.notes = notes
        self.modified = modified
        self.created = created
        self.tags = []  # SQLAlchemy backref

    def __repr__(self):
        truncate_len = 10
        title = truncate_str(self.title, truncate_len)
        url = truncate_str(self.url, truncate_len)
        return (f'<title="{title}", '
                f'url="{url}", '
                f'modified=({self.modified}), '
                f'created=({self.created}), '
                f'tags=({len(self.tags)} tags)>')

    def dump(self):
        return {'id': self.id_,
                'title': self.title,
                'url': self.url,
                'notes': self.notes,
                'modified': self.modified,
                'created': self.created,
                'tags': self.tags}


class BookmarkTag(Base, _JSONSeriallizable):
    __tablename__ = 'bookmark_tag'

    id_ = Column(Integer, primary_key=True)
    name = Column(Text, nullable=False)
    bookmarks = relationship('Bookmark',
                             secondary=bookmark_and_bookmark_tag_association_table,
                             backref='tags')

    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return (f'<name="{self.name}", '
                f'bookmarks=({len(self.bookmarks)} bookmarks)>')

    def dump(self):
        return {'id': self.id_,
                'tag': self.name,
                'bookmarks': self.bookmarks}
