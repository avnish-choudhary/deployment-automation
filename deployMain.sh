#!/bin/bash

BRANCH=${1:-uat}
DIR='cerebro'
PROPERTY_FILE=deployedApps.properties
JAVA_HOME='/usr/lib/jvm/java-8-oracle'
HOME_PATH='/home/ubuntu/'
BASE_PATH=$HOME_PATH$DIR
DEPLOY_PATH=$HOME_PATH'deployment'
DEPLOYED_PROPERTIES=$DEPLOY_PATH/$PROPERTY_FILE
APP_NAME='app8080'
REPLACE_BRANCH=false
DEPLOYED_BRANCH="`cat $DEPLOYED_PROPERTIES | grep "$APP_NAME" | cut -d'=' -f2`"

set -e

if [ -n "$DEPLOYED_BRANCH" ]; then
	if [ "$DEPLOYED_BRANCH" != "$BRANCH" ]; then
		while true; do
    			read -p "Do you want to replace the existing $DEPLOYED_BRANCH branch ?" yn
    			case $yn in
        			[Yy]* ) REPLACE_BRANCH=true; break;;
       				[Nn]* ) exit;;
        			* ) echo "Please answer yes or no.";;
    			esac
		done
	fi
fi	

if [ "$REPLACE_BRANCH" = true ]; then 
	sh $DEPLOY_PATH/sendNotification.sh "Replacing the current $DEPLOYED_BRANCH branch with $BRANCH on 8080"
else 
	sh $DEPLOY_PATH/sendNotification.sh "Re-deploying $BRANCH branch on 8080"
fi


cd $BASE_PATH

# checkout branch and pull changes
git checkout $BRANCH

git pull

new_properties=$DEPLOY_PATH/$APP_NAME'.properties'
app_properties=$BASE_PATH'/src/main/resources/application.properties'
sh $DEPLOY_PATH/updateProperties.sh $new_properties $app_properties

#build with min coverage as 0
mvn install -DskipTests -DminCoverage=0.0

#stopping application
echo "Stopping Application"
sudo kill $(cat app.pid)
echo "Application Killed Successfully"
# Restart application
echo "Starting Application"
sudo nohup java -jar $BASE_PATH/target/$DIR-0.0.1-SNAPSHOT.jar &
# copy pid to file
echo $! >| app.pid

sed -ir "s/^[#]*\s*app8080=.*/app8080=$BRANCH/" $DEPLOYED_PROPERTIES

timeout 300 sh healthCheck.sh

sh $DEPLOY_PATH/sendNotification.sh "Deployed successfully."
