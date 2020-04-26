#!/bin/sh
HOME_DIR='/home/ubuntu'
PROPERTY_FILE=$HOME_DIR/deployment/deployedApps.properties
cd $HOME_DIR
if [ "$1" != "cerebro" -a -d $1 ]; then
	echo "Stopping Application for $1"
	sudo kill $(cat $1/$1.pid)
	echo "$1 application Killed Successfully"
	rm -rf $1
	sed "/1=$1/d" -i $PROPERTY_FILE
        sed "/1=$2/d" -i $PROPERTY_FILE
        sed "/1=$3/d" -i $PROPERTY_FILE

	sh $HOME_DIR/deployment/sendNotification.sh "<!here> $1 branch has been reverted"
else 
	echo "$1 branch is not yet deployed"
fi
