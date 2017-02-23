#!/bin/bash

sudo restart spinnaker

# Wait up to 120 seconds for Spinnaker services to be ready:
# Gate - port 8084
# Clouddriver - port 7002
# Front50 - port 8080
# Orca - port 8083
count=0
timeout=120
while !(nc -z localhost 8080) || !(nc -z localhost 8084) || !(nc -z localhost 7002) || !(nc -z localhost 8083); do
  if [ $count -gt $timeout ]; then
    echo "Could not connect to Spinnaker." 1>&2
    exit 124 # same exit code used by 'timeout' function
  else
    sleep 1
    ((count++))
  fi
done