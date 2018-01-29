"""Application models"""

from datetime import datetime

from bookie.extensions import db
from .utils import datetime_utils
from .utils import string_utils

__all__ = ['Bookmark', 'Tag']


class BookieModel:
    def dump(self):
        raise NotImplementedError(
            f'dumps not implemented in subclass {self.__class__.__name__}'
            )


class Bookmark(db.Model, BookieModel):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.Text, nullable=False)
    url = db.Column(db.Text, nullable=False)
    notes = db.Column(db.Text, nullable=False)
    modified = db.Column(db.DateTime, nullable=False)
    created = db.Column(db.DateTime, nullable=False)
    tags = db.relationship(
        'Tag',
        secondary=lambda: bookmark_and_bookmark_tag_association_table,
        back_populates='bookmarks',
        lazy='joined'
    )

    def __init__(self,
                 title,
                 url,
                 notes='',
                 modified=datetime.now(),
                 created=datetime.now(),
                 **kwargs):
        db.Model.__init__(self, **kwargs)

        self.title = title
        self.url = url
        self.notes = notes
        self.modified = modified
        self.created = created
        self.tags = []  # SQLAlchemy backref

    def __repr__(self):
        truncate_len = 10
        title = string_utils.truncate_str(self.title, truncate_len)
        url = string_utils.truncate_str(self.url, truncate_len)
        return (f'<title="{title}", '
                f'url="{url}", '
                f'modified=({self.modified}), '
                f'created=({self.created}), '
                f'tags=({len(self.tags)} tags)>')

    def dump(self):
        return {'id': self.id,
                'title': self.title,
                'url': self.url,
                'notes': self.notes,
                'modified': datetime_utils.datetime_dump(self.modified),
                'created': datetime_utils.datetime_dump(self.created),
                'tags': [{'id': tag.id, 'name': tag.name} for tag in self.tags]}


class Tag(db.Model, BookieModel):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text, nullable=False)
    bookmarks = db.relationship(
        'Bookmark',
        secondary=lambda: bookmark_and_bookmark_tag_association_table,
        back_populates='tags',
        lazy='noload'
    )

    def __init__(self, name, **kwargs):
        db.Model.__init__(self, **kwargs)

        self.name = name
        self.tags = []  # SQLAlchemy backref

    def __repr__(self):
        return (f'<name="{self.name}", '
                f'bookmarks=({len(self.bookmarks)} bookmarks)>')

    def dump(self):
        dict_ = {'id': self.id,
                 'tag': self.name}

        if (self.bookmarks): dict_['bookmarks'] = self.bookmarks

        return dict_


bookmark_and_bookmark_tag_association_table = db.Table(
    'bookmark_and_bookmark_tag_association',
    db.Column('bookmark_id', db.Integer, db.ForeignKey('bookmark.id')),
    db.Column('tag_id', db.Integer, db.ForeignKey('tag.id'))
)
