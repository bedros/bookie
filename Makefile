server.debug:
	FLASK_DEBUG=1 src/bookie-server/manage.py run

server.test:
	python src/server/manage.py test

deploy.heroku:
	scripts/deploy-heroku.sh
