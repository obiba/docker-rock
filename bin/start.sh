#!/bin/bash

# Make sure conf folder is available
if [ ! -d $ROCK_HOME/conf ]
	then
	mkdir -p $ROCK_HOME/conf
	cp -r /usr/share/rock/conf/* $ROCK_HOME/conf
fi

# Start rserver
/usr/share/rock/bin/rock
