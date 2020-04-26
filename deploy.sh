#!/bin/bash

branch=$1
port=$2
dir=$branch
HOME_DIR='/home/ubuntu'
DEPLOY_PATH=$HOME_DIR'/deployment'
PROPERTY_FILE=deployedApps.properties
MSG='Deploying'

source $DEPLOY_PATH/deployment.config

if [ -z "$branch" ]; then
	echo "Please provide your branch name"
	exit
fi

if { set -C; 2>/dev/null >~/.deployment.lock; }; then
	echo "Checking Port Availability..."
else
	echo "Deployment Already Running... exiting"
	exit
fi

set -e

cleanup() {
	if [ -z "$completed" ]; then
		echo "Deployment aborted for $branch"
	else if [ "$delete" = true ]; then
		rm -rf ~/$branch
	fi
	fi
	if [ "$notify" = true ]; then
		sh sendNotification.sh "Deployment Aborted"
	fi
	rm -f ~/.deployment.lock
}

trap cleanup EXIT

validateBranchName() {
	if [ "`git branch --list $branch`" ]
	then
   		echo "$branch branch is valid."
	else 
		echo "$branch branch doesn't exist" 
		exit
	fi
}

checkPortAvailability() {
	
	if [ -n "$port" ]; then
		if [ -f "$DEPLOY_PATH/app$port.properties" -a -z "`cat $PROPERTY_FILE | grep "app$port" | cut -d'=' -f2`" ]; then
			echo "$port port is available"
       		else 
	       		echo "$port port is not available"
	       		exit
      		fi
	fi
}

findAvailablePort() {
        
	if [ -z "`cat $PROPERTY_FILE | grep "app8081" | cut -d'=' -f2`" ]; then
                SLOT='app8081'
                echo "Application starting using $SLOT"
        else if [ -z "`cat $PROPERTY_FILE | grep "app8082" | cut -d'=' -f2`" ]; then
                SLOT='app8082'
                echo "Application starting using $SLOT"
        else if [ -z "`cat $PROPERTY_FILE | grep "app8083" | cut -d'=' -f2`" ]; then
                SLOT='app8083'
                echo "Application starting using $SLOT"
        else    
                echo "There is no slot available for deployment"
                exit    
        fi      
        fi
        fi
}

cd $HOME_DIR/$REPOSITORY
validateBranchName

cd $HOME_DIR
if [ -d "$dir" ]; then
	cd $HOME_DIR/deployment
	dir=$branch
	if [ -z "$port" ]; then
		APP="`cat $PROPERTY_FILE | grep "1=$branch\|2=$branch\|3=$branch" | cut -d'=' -f1`"
	else
		APP="app$port"
		checkPortAvailability
		sed -ir "s/^[#]*\s*1=$branch.*/$APP=$branch/" $PROPERTY_FILE
		sed -ir "s/^[#]*\s*2=$branch.*/$APP=$branch/" $PROPERTY_FILE
		sed -ir "s/^[#]*\s*3=$branch.*/$APP=$branch/" $PROPERTY_FILE
	fi
        echo "This branch is already deployed"
	echo "Redeploying this branch"
	MSG='Re-deploying'
	delete=false
else 
	checkPortAvailability
	cp -r $REPOSITORY/ $dir 2>/dev/null || :
	#rsync -rv --exclude=nohup.out --stats $REPOSITORY/ $dir
	cd $HOME_DIR/deployment
	if [ -z "$port" ]; then
		findAvailablePort
		APP=$SLOT
	else 
		APP="app$port"
	fi
	echo "$APP=$branch" >> $PROPERTY_FILE	
fi

echo 'App : '$APP

if [ -z "$port" ]; then
	port="`cat $APP.properties | grep "server.port" | cut -d'=' -f2`"
fi

sh sendNotification.sh "<!here> $MSG $branch branch on $port"
notify=true

bash deployApp.sh $branch $APP

timeout 300 sh healthCheck.sh $port

sh sendNotification.sh "Deployed successfully"
notify=false
completed=true
echo "Application running on $port"
