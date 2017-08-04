from flask import render_template

from .app import bookmark_manager


@bookmark_manager.route('/')
def route_index():
    return render_template('index.jinja')
