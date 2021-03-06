#!/bin/bash

DIR=$1
JAVA_HOME='/usr/lib/jvm/java-8-oracle'
HOME_PATH='/home/ubuntu'
BASE_PATH=$HOME_PATH/$DIR
DEPLOY_PATH=$HOME_PATH/deployment

source $DEPLOY_PATH/deployment.config

JAR_APP_NAME=$REPOSITORY

# set -e

cd $BASE_PATH

# checkout branch and pull changes
git checkout $1

git pull

new_properties=$DEPLOY_PATH/$2'.properties'
app_properties=$BASE_PATH'/src/main/resources/application.properties'
sh $DEPLOY_PATH'/updateProperties.sh' $new_properties $app_properties

#build with min coverage as 0
mvn install -DskipTests -DminCoverage=0.0

#stopping application
echo "Stopping Application"
sudo pkill -9 -f java 2> /dev/null
echo "Application Killed Successfully"

# Start application
echo "Starting Application"
nohup java -jar $BASE_PATH/target/$JAR_APP_NAME-0.0.1-SNAPSHOT.jar &
# copy pid to file
echo $! >| $1.pid
