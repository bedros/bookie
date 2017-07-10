#!/bin/bash

git checkout heroku

cat > config.json <<- EOM
{
    "database_provider": "sqlite",
    "database_uri": "heroku.db",
    "debug": "false"
}
EOM

make frontend

virtualenv venv
pip install -r requirements.txt

export CREATE_DB=1
timeout 5s make debug