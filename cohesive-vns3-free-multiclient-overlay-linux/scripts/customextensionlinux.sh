#!/bin/bash

apt-get update
apt-get install -y openvpn
apt-get install -y ruby

curl https://s3.amazonaws.com/cohesive-networks/dnld/VNS3_4x_API_TOOL_20171114.tar.gz | tar xvz
mv  VNS3_434API_TOOL_20171114 api

chmod 700 api/vnscubed.rb
chmod 700 api/api.rb

sleep 1200

wait_for_api () {
   while :
     do
     apistatus=`curl -k -X GET -u api:vnscubed https://10.10.10.10:8000/api/config 2>&1`
        echo $apistatus | grep "refused"
          if [ $? != 0 ] ; then
            break
          fi
         sleep 2
     done
 }

wait_for_api

NAME=$(api/vnscubed.rb -K api -S vnscubed -H 10.10.10.10 get_next_available_clientpack | grep 'name')

IP=${NAME:7:15}

api/vnscubed.rb -K api -S vnscubed -H 10.10.10.10 fetch_clientpack --name "$IP" --format "conf" -o "clientpack.conf"

mv clientpack.conf /etc/openvpn

systemctl start openvpn@clientpack.service
