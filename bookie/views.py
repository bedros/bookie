from flask import render_template

from bookie import app


@app.route('/')
def route_index():
    return render_template('index.jinja')
