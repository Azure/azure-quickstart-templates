#!/bin/bash

clear
echo "This script will setup a Bloq Enterprise Router.\n"

echo "To use this script you have to be using Ubuntu 14.04.\n"

echo "Adding Bloq Enterprise Repo...\n"   
sudo apt-add-repository 'deb https://pkg.bloqenterprise.net/ stable main'

echo "Receiving GPG keys...\n"
sudo gpg #init trustdb
sudo gpg --recv-key 91955EB3D6410A98 
sudo gpg -a --export 91955EB3D6410A98 | sudo apt-key add -

echo "Performing update...\n"
sudo apt-get update > /dev/null 2>&1

echo "Installing and configuring BER...\n"
sudo apt-get -y install router-bloq > /dev/null 2>&1

PASSWORD="$(od -vAn -N8 -tx < /dev/urandom | tr -d ' ')"
sudo mkdir /root/.bitcoin
echo "Configuring BER ...\n"
#bind=0.0.0.0
#rpcbind=0.0.0.0
#rpcallowip=0.0.0.0/0 Add this line below to enable connections from the internet
cat << EOF > /root/.bitcoin/bitcoin.conf
printtoconsole=1
listen=1
daemon=1
server=1
rpcuser=rpcuser
rpcpassword=$PASSWORD
EOF

echo "Configuring upstart ...\n"
cat << EOF > /etc/init/ber.conf
    description "BER Node Service"
    script
      exec /usr/local/bin/bitcoind -conf=/root/.bitcoin/bitcoin.conf
    end script
EOF
chmod +x /etc/init/ber.conf
sudo service ber start

echo 'BER started, enabled, installed...done.'
