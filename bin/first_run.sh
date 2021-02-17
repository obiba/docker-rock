#!/bin/bash

echo "[Info] Applying config..."

# Configure node properties
echo "[Info] Node properties"
if [ -n "$ROCK_SERVER" ]
then
	sed s,@rock_server@,$ROCK_SERVER,g $ROCK_HOME/conf/application.yml > /tmp/application.yml
else
	echo "[Warn] No server public address: self-registration not activated"
	sed s,@rock_server@,,g $ROCK_HOME/conf/application.yml > /tmp/application.yml
fi
mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml

if [ -n "$ROCK_ID" ]
then
	sed s/@rock_id@/$ROCK_ID/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
else
	echo "[Warn] Setting default node id: rserver"
	sed s/@rock_id@/rserver/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
fi
mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml

if [ -n "$ROCK_TAGS" ]
then
	sed s/@rock_tags@/$ROCK_TAGS/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
else
	echo "[Info] Setting default node tags: default"
	sed s/@rock_tags@/default/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
fi
mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml

# Consul properties
echo "[Info] Consul properties"
if [ -n "$ROCK_CONSUL_SERVER" ]
then
	sed s,@rock_consul_server@,$ROCK_CONSUL_SERVER,g $ROCK_HOME/conf/application.yml > /tmp/application.yml
else
	echo "[Info] No Consul server: self-registration not activated"
	sed s,@rock_consul_server@,,g $ROCK_HOME/conf/application.yml > /tmp/application.yml
fi
mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml

if [ -n "$ROCK_CONSUL_TOKEN" ]
then
	sed s,@rock_consul_token@,$ROCK_CONSUL_TOKEN,g $ROCK_HOME/conf/application.yml > /tmp/application.yml
else
	echo "[Warn] No Consul token: self-registration not safe"
	sed s,@rock_consul_token@,,g $ROCK_HOME/conf/application.yml > /tmp/application.yml
fi
mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml

# Opal properties
echo "[Info] Opal properties"
if [ -n "$ROCK_OPAL_SERVER" ]
then
	sed s,@rock_opal_server@,$ROCK_OPAL_SERVER,g $ROCK_HOME/conf/application.yml > /tmp/application.yml
else
	echo "[Info] No Opal server: self-registration not activated"
	sed s,@rock_opal_server@,,g $ROCK_HOME/conf/application.yml > /tmp/application.yml
fi
mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml

if [ -n "$ROCK_OPAL_TOKEN" ]
then
	sed s,@rock_opal_token@,$ROCK_OPAL_TOKEN,g $ROCK_HOME/conf/application.yml > /tmp/application.yml
else
	echo "[Warn] No OPAL token: self-registration not valid"
	sed s,@rock_opal_token@,,g $ROCK_HOME/conf/application.yml > /tmp/application.yml
fi
mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml

# R properties
echo "[Info] R properties"
if [ -n "$ROCK_REPOS" ]
then
	sed 's;@rock_repos@;$ROCK_REPOS;g' $ROCK_HOME/conf/application.yml > /tmp/application.yml
else
	echo "[Info] No R repositories, setting default"
	sed 's;@rock_repos@;https://cloud.r-project.org,https://cran.obiba.org;g' $ROCK_HOME/conf/application.yml > /tmp/application.yml
fi
mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml

# Configure users
echo "[Info] Users properties"
# administrator
if [ -n "$ROCK_ADMINISTRATOR_NAME" ]
then
	sed s/@rock_administrator_name@/$ROCK_ADMINISTRATOR_NAME/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
	if [ -n "$ROCK_ADMINISTRATOR_PASSWORD" ]
	then
		sed s/@rock_administrator_password@/$ROCK_ADMINISTRATOR_PASSWORD/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	else
		echo "[Info] Setting default administrator password: password"
		sed s/@rock_administrator_password@/password/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	fi
	mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
else
	echo "[Info] No administrator configured!"
	sed s/@rock_administrator_name@//g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
fi
# manager
if [ -n "$ROCK_MANAGER_NAME" ]
then
	sed s/@rock_manager_name@/$ROCK_MANAGER_NAME/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
	if [ -n "$ROCK_MANAGER_PASSWORD" ]
	then
		sed s/@rock_manager_password@/$ROCK_MANAGER_PASSWORD/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	else
		echo "[Info] Setting default manager password: password"
		sed s/@rock_manager_password@/password/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	fi
	mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
else
	echo "[Info] No manager configured!"
	sed s/@rock_manager_name@//g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
fi
# user
if [ -n "$ROCK_USER_NAME" ]
then
	sed s/@rock_user_name@/$ROCK_USER_NAME/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
	if [ -n "$ROCK_USER_PASSWORD" ]
	then
		sed s/@rock_user_password@/$ROCK_USER_PASSWORD/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	else
		echo "[Info] Setting default user password: password"
		sed s/@rock_user_password@/password/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	fi
	mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
else
	echo "[Info] No user configured!"
	sed s/@rock_user_name@//g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
fi
