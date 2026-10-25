#!/bin/bash
set -e

echo "[Info] ROCK_HOME=$ROCK_HOME"

if [ "$1" = 'app' ]; then
    # Make sure conf folder is available
    if [ ! -d $ROCK_HOME/conf ]
    then
      mkdir -p $ROCK_HOME/conf
      cp -r /usr/share/rock/conf/* $ROCK_HOME/conf
    fi

    # Started as root: own the volume for the rock user and drop to it; otherwise run as the current user
    if [ "$(id -u)" = 0 ]
    then
      chown -R rock "$ROCK_HOME"
      RUN_AS="gosu rock"
    fi

    # First-run marker lives on the volume, next to the configuration it produced
    if [ ! -f $ROCK_HOME/conf/.first_run.done ]
    then
      echo "First run setup..."
      /opt/obiba/bin/first_run.sh
      touch $ROCK_HOME/conf/.first_run.done
    fi

    exec $RUN_AS /opt/obiba/bin/start.sh
fi

exec "$@"
