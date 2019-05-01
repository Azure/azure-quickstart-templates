#!/bin/bash

apt-get update
apt-get install -y openvpn
apt-get install -y ruby

mkdir api

curl https://raw.githubusercontent.com/HKF1977/MyGit/master/vnscubed.rb > api/vnscubed.rb
curl https://raw.githubusercontent.com/HKF1977/MyGit/master/api.rb > api/api.rb

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