#!/bin/bash
set -e

if [ "$1" = 'app' ]; then
    chown -R rock "$ROCK_HOME"

    exec gosu rock /opt/obiba/bin/start.sh
fi

exec "$@"
