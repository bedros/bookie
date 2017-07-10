#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cat > config.json <<-EOM
{
    "database_provider": "sqlite",
    "database_uri": "dev.db",
    "debug": "true"
}
EOM
