#!/bin/bash
userPassword=$1

#get the VM's public ip
curl ifconfig.me > /tmp/ip.txt 2> /dev/null


#download the packages
cd /tmp
#wget -c http://swupdate.openvpn.org/as/openvpn-as-2.0-Ubuntu13.amd_64.deb
wget -c http://swupdate.openvpn.org/as/openvpn-as-2.0.24-CentOS7.x86_64.rpm

#install the software
rpm -ivh openvpn-as-2.0.24-CentOS7.x86_64.rpm

#update the password for user openvpn
#sudo echo "openvpn:$userPassword"|sudo chpasswd
echo "$userPassword" |passwd --stdin openvpn

#configure server network settings
/etc/init.d/openvpnas stop
cp /usr/local/openvpn_as/etc/db/config.db /usr/local/openvpn_as/etc/db/config.db.bak
/usr/local/openvpn_as/scripts/sqlite3 /usr/local/openvpn_as/etc/db/config.db .dump > /usr/local/openvpn_as/scripts/configdb.txt
for publicIp in `cat /tmp/ip.txt`
do
sed -i "/host.name/s/[0-9]\+\..*[0-9]\+/${publicIp}/" /usr/local/openvpn_as/scripts/configdb.txt
done
rm /usr/local/openvpn_as/etc/db/config.db
/usr/local/openvpn_as/scripts/sqlite3 < /usr/local/openvpn_as/scripts/configdb.txt /usr/local/openvpn_as/etc/db/config.db
/etc/init.d/openvpnas start


