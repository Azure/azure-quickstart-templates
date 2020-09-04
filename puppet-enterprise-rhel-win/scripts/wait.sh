#!/bin/bash
while :
do
  curl -k -s https://localhost:8140/status/v1/services | python -c 'import json,sys;obj=json.load(sys.stdin);sys.exit(0) if (obj["pe-master"]["state"] == "running") else sys.exit(1);'
  if [[ $? == 0 ]]; then
    exit
  fi
  sleep 5
done
sleep 3m
