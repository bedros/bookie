debug:
	FLASK_APP=bookie FLASK_DEBUG=1 flask run

init:
	scripts/init.sh

frontend: elm style

frontend_prod: elm_prod style

elm:
	elm-make frontend/Main.elm --output bookie/static/dist/main.js --warn --debug

elm_prod:
	elm-make frontend/Main.elm --output bookie/static/dist/main.js

style:
	elm-css Stylesheets.elm

format:
	elm-format --yes .
