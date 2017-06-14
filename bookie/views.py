from flask import render_template

from bookie import app
from bookie import dm
from bookie import models


@app.route('/')
def route_index():
    entries = dm.get_all(models.Bookmark)
    print(entries)
    return render_template('index.jinja', bookmarks=entries)
