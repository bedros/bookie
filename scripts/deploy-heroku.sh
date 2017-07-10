#!/bin/bash

echo
echo "Compiling the frontend code..."
echo "---------------------------------------------------------"
make frontend

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
echo "Done"