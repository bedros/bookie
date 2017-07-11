# Development Setup

In project root, create a `config.json`:

    {
        "database_provider": "sqlite",
        "database_uri": "dev.db",
        "debug": "true"
    }

Create a virtualenv and activate it, then run

    pip install -r requirements.txt

If no database file exists for sqlite (only one supported at the moment), run
this before launching the server

    scripts/init_db.py
    
To compile the frontend Elm code you will need to install the following (`-g` is optional and can be inserted in the following command after the word `install`)

    npm install -g elm elm-css
    
Compile the frontend (`y` when asked to install elm packages)

    make frontend
    
Start a debugging server

    make debug
    
Open up `http://localhost:5000` in a browser
    
# Issues

If something doesn't work right or something is missing, please report it as an
issue at [github.com/francium/bookie/issues](github.com/francium/bookie/issues)
