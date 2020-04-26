#!/bin/bash

HOME_PATH='/home/ubuntu'
DEPLOY_PATH=$HOME_PATH'/deployment'
PROPERTY_FILE=$DEPLOY_PATH/deployedApps.properties

if [ -z "`cat $PROPERTY_FILE | grep "app8081" | cut -d'=' -f2`" ]; then
        AVAILABLE_PORTS='8081'
fi
if [ -z "`cat $PROPERTY_FILE | grep "app8082" | cut -d'=' -f2`" ]; then
	if [ -z "$AVAILABLE_PORTS" ]; then
		AVAILABLE_PORTS=8082
	else
		AVAILABLE_PORTS=$AVAILABLE_PORTS,8082
	fi
fi
if [ -z "`cat $PROPERTY_FILE | grep "app8083" | cut -d'=' -f2`" ]; then
	if [ -z "$AVAILABLE_PORTS" ]; then
                AVAILABLE_PORTS="8083"
        else
 		AVAILABLE_PORTS="$AVAILABLE_PORTS and 8083"
        fi
fi

if [ -z "$AVAILABLE_PORTS" ]; then 
	echo "There are no available ports for deployment"
	exit
fi

echo "Available ports for deployment: $AVAILABLE_PORTS" 
