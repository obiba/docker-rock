#!/bin/bash

# Start rock
echo "Starting rock..."
mkdir -p $ROCK_HOME/logs
# native executable: no classpath, config locations are explicit
exec /usr/share/rock/bin/rock $JAVA_OPTS \
  --spring.config.additional-location=file:$ROCK_HOME/conf/ \
  --logging.config=file:$ROCK_HOME/conf/logback.xml
