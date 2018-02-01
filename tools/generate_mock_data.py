#!/bin/env python3


from random import gauss, randint, choice, choices

from bookie.app_factory import create_app
from bookie.extensions import db
from bookie.blueprints.bookmark_manager.models import *


NUM_BOOKMARKS = 1000
NUM_TAGS = 20


def gibberish_word(length: int) -> str:
    return ''.join([chr(randint(97, 122)) for _ in range(length)])


def gibberish_phrase(length: int, minWordSize=5, maxWordSize=10) -> str:
    return ' '.join([
        gibberish_word(randint(minWordSize, maxWordSize)) for _ in range(length)
    ])


def random_url(length: int) -> str:
    tld = '.com', '.net', '.org', '.edu'
    prefixes = 'http://', 'http://wwww.', 'https://', 'https://www.', 'www.', ''

    return choice(prefixes) + gibberish_word(length) + choice(tld)


def generate_mock_data():
    """
    :rtype: (Bookmark, Tag)
    """
    tags = []
    bookmarks = []

    for i in range(NUM_TAGS):
        name = gibberish_word(randint(1, 10))
        tags.append(Tag(name))

    for i in range(NUM_BOOKMARKS):
        title = gibberish_phrase(randint(1, 10))
        url = random_url(randint(1, 20))
        selected_tags = choices(tags, k=max(1, int(gauss(1, 3))))
        bookmarks.append(Bookmark(title, url, tags=selected_tags))

    return bookmarks, tags


def main():
    app = create_app()
    db.create_all(app=app)
    with app.app_context():
        bookmarks, tags = generate_mock_data()
        db.session.add_all(tags)
        db.session.add_all(bookmarks)
        db.session.commit()


if __name__ == '__main__':
    main()
