#!/bin/bash

HOME_DIR='/home/ubuntu'
DEPLOY_PATH=$HOME_DIR/deployment
PROPERTY_FILE=$DEPLOY_PATH/'deployedApps.properties'

source $DEPLOY_PATH/deployment.config

cd $HOME_DIR

if [ "$1" != "$REPOSITORY" -a -d $1 ]; then
	echo "Stopping Application for $1"
	sudo kill $(cat $1/$1.pid)
	echo "$1 application Killed Successfully"
	rm -rf $1
	sed "/1=$1/d" -i $PROPERTY_FILE
        sed "/2=$1/d" -i $PROPERTY_FILE
        sed "/3=$1/d" -i $PROPERTY_FILE

	sh $HOME_DIR/deployment/sendNotification.sh "<!here> $1 branch has been reverted"
else 
	echo "$1 branch is not yet deployed"
fi
