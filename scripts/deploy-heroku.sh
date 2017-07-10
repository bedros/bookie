#!/bin/bash

make frontend

git checkout heroku

cat > config.json <<- EOM
{
    "database_provider": "sqlite",
    "database_uri": "heroku.db",
    "debug": "false"
}
EOM

virtualenv venv
pip install -r requirements.txt

export CREATE_DB=1
export FLASK_APP=bookie
timeout 5s flask run