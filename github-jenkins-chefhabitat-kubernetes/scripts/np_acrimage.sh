#!/bin/bash
exec 2>&1

ACR=ossacr
Uname=ossAcr
Password=$1  # Input password of ACR

SRC_DIR="/root/MSOSS/national-parks-plan-kubernetes/results"
FILEEXT="hart"
HART=`ls -tr1d "${SRC_DIR}/"*.${FILEEXT} 2>/dev/null | tail -1`

echo $SRC_DIR
echo $HART

if [ ! -d "$SRC_DIR" ] > /dev/null
then
        echo "Please build the package first before running the script"
else
        hab pkg export docker $HART >> /scripts/np-dockerimage.log
        DIMAGE=`docker images | grep -E 'root/national-parks.*latest' | awk -e '{print $3}'`
        docker tag $DIMAGE $ACR.azurecr.io/national-parks:latest
        docker login https://$ACR.azurecr.io --username $Uname --password $Password
        docker push $ACR.azurecr.io/national-parks:latest

fi
