from sqlalchemy import ( Column
                       , ForeignKey
                       , Integer
                       , String
                       )
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship


Base = declarative_base()


class _JSONSeriallizable():
    def dump(self):
        raise NotImplementedError('dumps not implemented in subclass '
                                  + self.__class__.__name__
                                  )


class Bookmark(Base, _JSONSeriallizable):
    __tablename__ = 'bookmark'

    id_ = Column(Integer, primary_key=True)
    title = Column(String(512), nullable=False)
    url = Column(String(4096), nullable=False)
    description = Column(String(1024), nullable=True)

    def dump(self):
        return {'id': self.id_,
                'title': self.title,
                'url': self.url,
                'description': self.description,
                }


class BookmarkTag(Base, _JSONSeriallizable):
    __tablename__ = 'bookmark_tag'

    id_ = Column(Integer, primary_key=True)
    tag = Column(String(64), nullable=False)
    bookmark_id = Column(Integer, ForeignKey('bookmark.id_'))
    bookmark = relationship(Bookmark)

    def dump(self):
        return {'id': self.id_,
                'tag': self.tag,
                'bookmark_id': self.bookmark_id,
                }
