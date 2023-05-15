#!/bin/bash
userPassword=$1

# adding official OpeenVPN Access Servere repository
sudo apt update && sudo apt -y install ca-certificates wget net-tools
wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | sudo apt-key add -
sudo sh -c 'echo "deb http://as-repository.openvpn.net/as/debian bionic main">>/etc/apt/sources.list.d/openvpn-as-repo.list'

# installing the OpenVPN Serve
sudo apt update && sudo apt -y install openvpn-as

#update the password for user openvpn
sudo echo "openvpn:$userPassword"|sudo chpasswd

#configure server network settings
PUBLICIP=$(curl -s ifconfig.me)
sudo apt-get install sqlite3
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "update config set value='$PUBLICIP' where name='host.name';"

#restart OpenVPN AS service
sudo systemctl restart openvpnas
