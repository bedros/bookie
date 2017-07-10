#!/bin/bash

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
echo "Compiling the frontend code..."
echo "---------------------------------------------------------"
make frontend-prod

echo
echo "Creating a config.json file..."
echo "---------------------------------------------------------"
cat > config.json <<- EOM
{
    "database_provider": "sqlite",
    "database_uri": "heroku.db",
    "debug": "false"
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
echo "Launching server to create a initial database..."
echo "---------------------------------------------------------"
export CREATE_DB=1
timeout 5s make debug

echo
echo "Adding fresh heroku.db database for deployment..."
echo "---------------------------------------------------------"
git add -f heroku.db config.json bookie/static/dist
git commit -m "sciprt :: Added heroku.db for deployment."

echo
echo "Pushing to heroku..."
echo "---------------------------------------------------------"
git push heroku deploy/heroku:master

echo
echo "Done"
