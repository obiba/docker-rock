#!/bin/bash
set -e

echo "[Info] ROCK_HOME=$ROCK_HOME"

if [ "$1" = 'app' ]; then
    # Make sure conf folder is available
    if [ ! -d $ROCK_HOME/conf ]
    	then
    	mkdir -p $ROCK_HOME/conf
    	cp -r /usr/share/rock/conf/* $ROCK_HOME/conf
      # reinstating init script
      if [ -f /opt/obiba/bin/first_run.sh.done ]
      then
        mv /opt/obiba/bin/first_run.sh.done /opt/obiba/bin/first_run.sh
      fi
    fi
    chown -R rock "$ROCK_HOME"

    if [ -f /opt/obiba/bin/first_run.sh ]
    then
      echo "First run setup..."
      /opt/obiba/bin/first_run.sh
      mv /opt/obiba/bin/first_run.sh /opt/obiba/bin/first_run.sh.done
    fi

    # FIXME AppArmor init
    #service apparmor restart
    #aa-disable usr.bin.r

    exec gosu rock /opt/obiba/bin/start.sh
fi

exec "$@"
