serve:
	FLASK_APP=bookie flask run

test.backend:
	python -m unittest -v

test.frontend:
	echo "TODO"

frontend: elm style

frontend.prod: elm_prod style

elm:
	elm-make frontend/Main.elm --output bookie/static/dist/main.js --warn --debug

elm.prod:
	elm-make frontend/Main.elm --output bookie/static/dist/main.js

style:
	elm-css Stylesheets.elm

format:
	elm-format --yes .

deploy.heroku:
	scripts/deploy-heroku.sh
