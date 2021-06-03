#!/bin/bash

apt-get update
apt-get install -y openvpn
apt-get install -y ruby

curl https://s3.amazonaws.com/cohesive-networks/dnld/vnscubed-ruby-cli-20200827.tar.gz | tar xvz
mv  vnscubed-ruby-cli-20200827 api

chmod 700 api/vnscubed.rb
chmod 700 api/api.rb

sleep 600

wait_for_api () {
   while :
     do
     apistatus=`curl -k -X GET -u api:VNS3Controller-10.10.10.10 https://10.10.10.10:8000/api/config 2>&1`
        echo $apistatus | grep "refused"
          if [ $? != 0 ] ; then
            break
          fi
         sleep 2
     done
 }

wait_for_api

NAME=$(api/vnscubed.rb -K api -S VNS3Controller-10.10.10.10 -H 10.10.10.10 get_next_available_clientpack | grep 'name')

IP=${NAME:7:13}

api/vnscubed.rb -K api -S VNS3Controller-10.10.10.10 -H 10.10.10.10 fetch_clientpack --name "$IP" --fileformat "conf" -o "clientpack.conf"

mv clientpack.conf /etc/openvpn

systemctl start openvpn@clientpack.service

curl https://cn-dnld.s3.amazonaws.com/cohesive-ra_1.1.1_x86_64.deb --output cohesive_ra_1.1.1_amd64.deb

dpkg -i cohesive_ra_1.1.1_amd64.deb &> /dev/null