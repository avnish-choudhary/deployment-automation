#!/bin/bash

port=${1:-8080}

while true
do
  STATUS="$(curl -s -o /dev/null -w '%{http_code}' --header 'Authorization: Basic QGRNMU46UEAkJFcwckQ=' http://localhost:$port/api/v1/healthCheck)"
  if [ "$STATUS" -eq 200 ]; then
    echo "Got 200! Application started successfully!"
    break
  else
    echo "Not Running ... Will check again in 10 secs"
  fi
  sleep 10
done
