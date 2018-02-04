from flask import render_template

from .app import bookmark_manager_bp


@bookmark_manager_bp.route('/')
def route_index():
    return render_template('index.jinja')
