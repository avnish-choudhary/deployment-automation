#!/bin/bash
deployment_path='/home/ubuntu/deployment/'
file=$deployment_path'deployedApps.properties'
final_list="Today's Update:"

while IFS="=" read -r key value; do
	#port=$(echo "${key//app/g}")
	port=`echo $key | sed 's/app//1g'`
	final_list="$final_list"'\n'"$value branch on $port"
done < "$file"

if [ "$final_list" = '' ] ; then
	MSG='No feature branch deployed'
else
	MSG=$final_list
fi

echo $MSG
sh $deployment_path'sendNotification.sh' "$MSG"
