#!/bin/bash

clear
echo "This script will setup a Monero node."
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
sudo apt-get -y install nano htop unzip apt-utils ntp ca-certificates screen dialog ufw lbzip2 curl wget cron > /dev/null 2>&1
echo "---"
echo "Enabling Ubuntu's unattended security upgrades..."
sudo apt-get -y install unattended-upgrades > /dev/null 2>&1
echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee --append /etc/apt/apt.conf.d/20auto-upgrades > /dev/null 2>&1
echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee --append /etc/apt/apt.conf.d/20auto-upgrades > /dev/null 2>&1
echo "---"
UUID=$(cat /dev/urandom | tr -dc '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz' | fold -w 5 | head -n 1)
echo "Setting hostname to MoneroNode-$UUID..."
echo "MoneroNode-$UUID" | sudo tee --append /etc/hostname > /dev/null 2>&1
sudo hostname "MoneroNode-$UUID" > /dev/null 2>&1
echo "---"
echo "Configuring the UFW firewall..."
sudo ufw allow 22/tcp > /dev/null 2>&1
sudo ufw allow 18080/tcp > /dev/null 2>&1
sudo ufw --force enable > /dev/null 2>&1
echo "---"
echo "Installing and configuring Monero..."
cd ~
wget -q https://downloads.getmonero.org/linux > /dev/null 2>&1
tar -xf ~/linux > /dev/null 2>&1
rm ~/linux > /dev/null 2>&1
echo "---"
echo "Installing Monero watchdog..."
echo '#!/bin/bash' > ~/bm_watchdog.sh
echo 'if ! pgrep bitmonerod > /dev/null' >> ~/bm_watchdog.sh
echo 'then' >> ~/bm_watchdog.sh
echo '        screen -S bm -d -m ~/bitmonerod' >> ~/bm_watchdog.sh
echo 'fi' >> ~/bm_watchdog.sh
chmod +x ~/bm_watchdog.sh
echo "*/5 * * * * $(pwd)/bm_watchdog.sh" > ~/cronjobs
crontab ~/cronjobs > /dev/null 2>&1
rm ~/cronjobs > /dev/null 2>&1
echo "---"
echo "Starting Monero..."
~/bm_watchdog.sh > /dev/null 2>&1
echo "---"
echo 'All done!'
echo 'The Monero node will take anything from 1 to 3 hours to sync up for the first time,'
echo 'after which you can query it, or use a wallet client to access it. Please note that'
echo 'the RPC interface is only accessible on localhost, and is not served over the'
echo 'Internet. To change this, add a --rpc-bind-ip 0.0.0.0 flag to the watchdog script,'
echo 'located at ~/bm_watchdog.sh'

