debug:
	FLASK_APP=bookie FLASK_DEBUG=1 flask run

frontend: elm style

elm:
	elm-make frontend/Main.elm --output bookie/static/dist/main.js --warn --debug

style:
	elm-css Stylesheets.elm

format:
	elm-format --yes .
