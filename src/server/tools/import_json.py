import json
import sys

from bookie_server.blueprints.bookmark_manager.models import Bookmark
from bookie_server.foobaz_data_manager import DataManager as DM


def insert_list(data):
    for item in data:
        if item['title'] == 'Toolbar' or\
                item['title'] == 'Menu' or\
                item['type'] == 'folder':
            insert_list(item['children'])
        else:
            dm.insert(Bookmark(title=item['title'], url=item['url']))


if __name__ == '__main__':
    if (len(sys.argv) != 2):
        print('Missing argument: json file')
        sys.exit(1)

    json_file = sys.argv[1]

    with open(json_file) as fin:
        data = fin.read()

    data = json.loads(data)

    dm = DM('sqlite:///dev.db')

    insert_list(data)
