#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo
echo "Checking out deploy/heroku branch..."
echo "---------------------------------------------------------"
git checkout deploy/heroku
if [ $? != 0 ]; then
    echo
    echo "---------------------------------------------------------"
    echo "Deployment failed. Exiting"
    exit
fi

echo
echo "Merging in master..."
echo "---------------------------------------------------------"
git merge master

echo
echo "Compiling the frontend code..."
echo "---------------------------------------------------------"
make frontend

echo
echo "Creating a config.json file..."
echo "---------------------------------------------------------"
cat > config.json <<- EOM
{
    "database_provider": "postgresql+psycopg2",
    "debug": "true",
    "heroku": "true"
}
EOM

echo
echo "Creating a virtualenv..."
echo "---------------------------------------------------------"
virtualenv venv

echo
echo "Installing pip requirements..."
echo "---------------------------------------------------------"
pip install -r requirements.txt

echo
echo "Adding fresh heroku.db database for deployment..."
echo "---------------------------------------------------------"
git add -f heroku.db config.json bookie/static/dist
git commit --allow-empty -m "sciprt :: deployment to heroku."

echo
echo "Pushing to heroku..."
echo "---------------------------------------------------------"
git push heroku deploy/heroku:master

echo
echo "Checking out master branch..."
echo "---------------------------------------------------------"
git checkout master

echo
echo "Done"
