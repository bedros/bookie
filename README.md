# bookie - your bookmark manager


## Quickstart
TODO

## Demo
<div style="width: 100%; height: 0px; position: relative; padding-bottom: 56.250%;">
    <iframe src="https://streamable.com/s/hl330/pmjasp"
            frameborder="0" width="100%" height="100%" allowfullscreen
            style="width: 100%; height: 100%; position: absolute;">
    </iframe>
</div>


## Issues

If something doesn't work right or something is missing, please report it as an
issue at [github.com/francium/bookie/issues](github.com/francium/bookie/issues)


## Development Setup

(Optional, override the default config values otherwise the following default
config values would be used)
In project root, create a `config.json`:

    {
        "database_provider": "sqlite",
        "database_uri": "dev.db",
        "debug": "true",
        "port": 5000
    }

Create a virtualenv and activate it, then run

    pip install -r requirements.txt

To compile the frontend Elm code you will need to install the following
(`-g` is optional)

    npm install -g elm elm-css
    
Compile the frontend (`y` when asked to install elm packages)

    make frontend
    
Start a debugging server

    make debug
    
Open up `http://localhost:5000` (default port) in a browser
