#!/bin/bash
exec 2>&1

if pgrep -x "mongod" > /dev/null
then
        echo "mongod process is Running"
        processid=`ps -eaf | grep hab-sup | awk '{print $2,$3}' | head -n 1`
        kill -9 $processid
        echo "mongod process killed"
else
        echo "mongod process is not running"
fi

if pgrep -x "hab-sup" > /dev/null
then
        echo "hab-sup process is Running"
        processid=`ps -eaf | grep hab-sup | awk '{print $2,$3}' | head -n 1`
        kill -9 $processid
        echo "hab-sup process killed"
else
        echo "hab-sup process is not running"
        echo "Downloding the MongoDB HART File..."
        mkdir /scripts/MongoDBHart
        wget -P /scripts/MongoDBHart/ https://github.com/sysgain/MSOSS/raw/habcode/Mongodb.tar.gz
        tar -xzvf /scripts/MongoDBHart/Mongodb.tar.gz -C /scripts/MongoDBHart
        cp -vrf /scripts/MongoDBHart/root-20171009044452.pub /hab/cache/keys
        nohup hab sup start /scripts/MongoDBHart/root-mongodb-3.2.9-20171009054024-x86_64-linux.hart >> /scripts/sup-mongodb.log 2>1 &
fi
