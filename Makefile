server-debug:
	FLASK_APP=bookie FLASK_DEBUG=1 flask run

elm:
	cd bookie/static/scripts; \
		elm-make Main.elm --output index.js --warn --debug

elm-format:
	cd bookie/static/scripts; \
		elm-format --yes .
