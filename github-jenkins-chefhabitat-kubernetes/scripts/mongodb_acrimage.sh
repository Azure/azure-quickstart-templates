#!/bin/bash
exec 2>&1

ACR=ossacr
Uname=ossAcr
Password=$1
DIRECTORY="/scripts/MongoDBHart"

if [ -d "$DIRECTORY" ] > /dev/null
then
        echo "MongoDBHart DIRECTORY Exist. Hart file is already downloaded"
else
        mkdir /scripts/MongoDBHart
        wget -P /scripts/MongoDBHart/ https://github.com/sysgain/MSOSS/raw/habcode/Mongodb.tar.gz
        tar -xzvf /scripts/MongoDBHart/Mongodb.tar.gz -C /scripts/MongoDBHart
        cp -vrf /scripts/MongoDBHart/root-20171009044452.pub /hab/cache/keys
        hab pkg export docker /scripts/MongoDBHart/root-mongodb-3.2.9-20171009054024-x86_64-linux.hart >> /scripts/mongodb-dockerimage.log
        DIMAGE=`docker images | grep -E 'root/mongo.*latest' | awk -e '{print $3}'`
        docker tag $DIMAGE $ACR.azurecr.io/mongodb:latest
        docker login https://$ACR.azurecr.io --username $Uname --password $Password
        docker push $ACR.azurecr.io/mongodb:latest

fi
