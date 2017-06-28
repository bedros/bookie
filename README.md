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
this before launching the server (but remember to do `unset DB_CREATE` afterwards to avoid having the app try to recreate the server each time the server starts up)

    export CREATE_DB=1

Install the `bookie` project

    pip install --editable .
