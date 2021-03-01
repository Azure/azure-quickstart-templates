#!/bin/bash

usage(){
  echo "Invalid option: -$OPTARG"
  echo "Usage: deploy-deis -n [Resource group name]"
  echo "                   -l [Resource group location]"
  echo "                   -t [Template file]"
  echo "                   -p [Template parameters file]"
  echo "                   -c [Cloud init data file]"
  exit 1
}

while getopts ":n:l:f:e:c:" opt; do
  case $opt in
    n)GROUP_NAME=$OPTARG;;
    l)LOCATION=$OPTARG;;
    f)TEMPLATE=$OPTARG;;
    e)PARAMETERS=$OPTARG;;
    c)CLOUDINIT=$OPTARG;;
    *)usage;;
  esac
done

INITCONTENT=`cat "$CLOUDINIT"|base64 -w 0`
echo "\"customData\":{\"value\":\"$INITCONTENT\"}" > updatepattern.txt

cat $PARAMETERS | tr '\n' ' ' | sed "s/\"customData[^{]*{[^}]*}/$(sed 's:/:\\/:g' updatepattern.txt)/" > parms.json

azure config mode arm
azure group create -n "$GROUP_NAME" -l "$LOCATION" -f $TEMPLATE -e ./parms.json  -v

rm updatepattern.txt
rm parms.json
