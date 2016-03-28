#!/bin/bash
userPassword=$1

#get the VM's public ip
curl ifconfig.me > /tmp/ip.txt 2> /dev/null


#download the packages
cd /tmp
wget -c http://swupdate.openvpn.org/as/openvpn-as-2.0-Ubuntu13.amd_64.deb

#install the software
sudo dpkg -i openvpn-as-2.0-Ubuntu13.amd_64.deb

#update the password for user openvpn
sudo echo "openvpn:$userPassword"|sudo chpasswd

#configure server network settings
sudo /etc/init.d/openvpnas stop
sudo cp /usr/local/openvpn_as/etc/db/config.db /usr/local/openvpn_as/etc/db/config.db.bak
sudo /usr/local/openvpn_as/scripts/sqlite3 /usr/local/openvpn_as/etc/db/config.db .dump > /usr/local/openvpn_as/scripts/configdb.txt
for publicIp in `cat /tmp/ip.txt`
do
sudo sed -i "/host.name/s/[0-9]\+\..*[0-9]\+/${publicIp}/" /usr/local/openvpn_as/scripts/configdb.txt
done
sudo rm /usr/local/openvpn_as/etc/db/config.db
sudo /usr/local/openvpn_as/scripts/sqlite3 < /usr/local/openvpn_as/scripts/configdb.txt /usr/local/openvpn_as/etc/db/config.db
sudo /etc/init.d/openvpnas start


