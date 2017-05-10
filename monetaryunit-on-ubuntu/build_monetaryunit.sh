#!/bin/bash

clear
echo "This script will setup a MonetaryUnit node."
echo "---"
echo "To use this script you have to be using Ubuntu 14.04. It MAY work on other versions,"
echo "but let's not push our luck."
echo "---"
echo "Performing a general system update (this might take a while)..."
sudo apt-get update > /dev/null 2>&1
sudo apt-get -y upgrade > /dev/null 2>&1
sudo apt-get -y dist-upgrade > /dev/null 2>&1
echo "---"
echo "Installing prerequisites..."
sudo apt-get -y install software-properties-common > /dev/null 2>&1
sudo apt-add-repository ppa:monetaryunit/monetaryunit > /dev/null 2>&1
sudo apt-add-repository ppa:bitcoin/bitcoin > /dev/null 2>&1
sudo apt-get update > /dev/null 2>&1
sudo apt-get -y install apg monetaryunitd nano htop unzip apt-utils ntp ca-certificates dialog ufw lbzip2 curl wget cron > /dev/null 2>&1
echo "---"
echo "Enabling Ubuntu's unattended security upgrades..."
sudo apt-get -y install unattended-upgrades > /dev/null 2>&1
echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee --append /etc/apt/apt.conf.d/20auto-upgrades > /dev/null 2>&1
echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee --append /etc/apt/apt.conf.d/20auto-upgrades > /dev/null 2>&1
echo "---"
echo "Configuring the UFW firewall..."
sudo ufw allow 22/tcp > /dev/null 2>&1
sudo ufw allow 29948/tcp > /dev/null 2>&1
sudo ufw --force enable > /dev/null 2>&1
echo "---"
echo "Installing and configuring MonetaryUnit..."
cd /tmp
wget -q https://github.com/MonetaryUnit/MUE-Src/releases/download/v1.0.10.8/bootstrap-block_1400000.tar.xz > /dev/null 2>&1
tar -xf /tmp/bootstrap-block_1400000.tar.xz > /dev/null 2>&1
rm /tmp/bootstrap-block_1400000.tar.xz > /dev/null 2>&1
sudo mkdir /var/lib/monetaryunitd > /dev/null 2>&1
sudo mv bootstrap.dat /var/lib/monetaryunitd > /dev/null 2>&1
sudo mkdir /etc/monetaryunit > /dev/null 2>&1
printf '%s\n%s\n%s\n%s\n%s\n%s\n' 'datadir=/var/lib/monetaryunitd' 'daemon=1' 'server=1' 'rpcuser='$(apg -MCLN -m 32 -n1) 'rpcpassword='$(apg -MCLN -m 32 -n1) 'rpcallowip=127.0.0.1' | sudo tee /etc/monetaryunit/monetaryunit.conf
sudo adduser --system --no-create-home --group muedaemon > /dev/null 2>&1
sudo chown -R muedaemon:muedaemon /etc/monetaryunit > /dev/null 2>&1
sudo chown -R muedaemon:muedaemon /var/lib/monetaryunitd > /dev/null 2>&1
echo "---"
echo "Installing MonetaryUnit service..."
wget https://gist.github.com/upgradeadvice/9f58857caaf2dfae2c2e89d01c465991/raw/73ce798459b45bf828c18db62dda66b43e174371/monetaryunit.conf > /dev/null 2>&1
sudo mv monetaryunit.conf /etc/init/ > /dev/null 2>&1
echo "---"
echo "Starting MonetaryUnit..."
sudo service monetaryunit start > /dev/null 2>&1
echo "---"
echo 'All done!'
echo
echo 'The MonetaryUnit node will take a couple of hours to sync up for the first time,'
echo 'after which you can query it, or use a wallet client to access it. Please note that'
echo 'the RPC interface is only accessible on localhost. Add rpcallowip=<externalip> to /etc/monetaryunit.conf'
echo 'to allow an external IP address. Then sudo ufw allow 29947/tcp to allow remote connections.'
echo
echo 'Note that rpcuser and rpcpassword are randomly generated during setup'
echo
echo "It is also recommended that you also set alertnotify so you are notified of problems:"
echo "ie: alertnotify=echo %%s | mail -s \"Monetaryunit Alert\"" "admin@foo.com"
echo
echo 'Other notes:'
echo 'MonetaryUnit datadir and wallet are located at /var/lib/monetaryunitd.'
echo 'The node can be accessed via monetaryunit-cli ie: sudo -u muedaemon monetaryunit-cli -conf=/etc/monetaryunit/monetaryunit.conf getinfo'
echo 'The service can be controlled using the service command ie: service monetaryunit restart'
