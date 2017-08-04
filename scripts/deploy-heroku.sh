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
make frontend_prod

echo
echo "Creating a config.py file..."
echo "---------------------------------------------------------"
cat > config.json <<- EOM
{
    "database_provider": "postgresql+psycopg2",
    "heroku": true,
    "debug": "false"
}
EOM

echo
echo "Staging file for commit..."
echo "---------------------------------------------------------"
git add -f config.json bookie/static/dist
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
