debug:
	FLASK_APP=bookie FLASK_DEBUG=1 flask run

frontend: elm style

frontend-prod: elm-prod style

elm:
	elm-make frontend/Main.elm --output bookie/static/dist/main.js --warn --debug

elm-prod:
	elm-make frontend/Main.elm --output bookie/static/dist/main.js

style:
	elm-css Stylesheets.elm

format:
	elm-format --yes .
