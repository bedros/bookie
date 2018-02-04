#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cat > config.json <<-EOM
{
    "database_provider": "sqlite",
    "database_uri": "bookie.db",
    "debug": true,
    "port": 5000
}
EOM
