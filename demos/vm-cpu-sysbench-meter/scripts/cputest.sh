#!/bin/bash

#install sysbench
apt-get update > /dev/null
apt-get -y install sysbench > /dev/null

#run test
sysbench --test=cpu --num-threads=$1 --cpu-max-prime=$2 run | grep -E 'total time:|min:|max:|avg:|percentile:' | tr '\n' ':' | tr -d " " | awk -F"=|:" '{print $2, $4, $6, $8, $10}'
