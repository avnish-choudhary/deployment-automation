#!/bin/sh

file="$1"
dest="$2"

echo '------------------------------------------------------------------------'
echo '                       APPLICATION CONFIG CHANGES			      '
echo '------------------------------------------------------------------------'

while IFS="=" read -r key value; do
    	current_value=`sed -n "s/$key=//p" $dest`
    	if [ -z "$current_value" ]; then
		echo "  [ADDED]    $key = $value" 
		echo "$key=$value" >> $dest
    	else
	      	echo "  [UPDATED]  $key = $value"	
		sed -ir "s/^[#]*\s*$key=.*/$key=$value/" $dest
	fi
done < "$file"

echo '------------------------------------------------------------------------'
