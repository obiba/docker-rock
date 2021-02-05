#!/bin/bash

echo "[Info] Applying config..."

# Configure node properties
echo "[Info] Node properties"
if [ -n "$ROCK_ADDRESS" ]
then
	sed s,@rock_address@,$ROCK_ADDRESS,g $ROCK_HOME/conf/application.yml > /tmp/application.yml
	mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
else
	echo "[Error] ROCK_ADDRESS is required!"
fi

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

# Configure AppArmor
echo "[Info] AppArmor properties"
if [ -n "$ROCK_APPARMOR_ENABLED" ]
then
	sed s/@rock_apparmor_enabled@/$ROCK_APPARMOR_ENABLED/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
else
	echo "[Info] Setting default apparmor enabled: false"
	sed s/@rock_apparmor_enabled@/false/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
fi
mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
# TODO install AppArmor profile files and restart apparmor service
if [ -n "$ROCK_APPARMOR_PROFILE" ]
then
	sed s/@rock_apparmor_profile@/$ROCK_APPARMOR_PROFILE/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
else
	echo "[Info] Setting default apparmor profile: testprofile"
	sed s/@rock_apparmor_profile@/testprofile/g $ROCK_HOME/conf/application.yml > /tmp/application.yml
fi
mv -f /tmp/application.yml $ROCK_HOME/conf/application.yml
