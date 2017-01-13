#!/bin/bash
sudo apt-get -y update
sudo apt-get -y install build-essential git-all rake
wget https://packages.chef.io/stable/ubuntu/12.04/chefdk_0.14.25-1_amd64.deb -O /home/adminuser/chefdk_0.14.25-1_amd64.deb
sudo dpkg -i /home/adminuser/chefdk_0.14.25-1_amd64.deb
wget https://raw.githubusercontent.com/boobalana/bbrepo1/delivery-branch/config -O /home/adminuser/.ssh/config
wget https://raw.githubusercontent.com/boobalana/bbrepo1/delivery-branch/id_rsa -O /home/adminuser/.ssh/id_rsa
wget https://github.com/sysgain/cloudtry-p2p-public-artifacts/raw/master/scripts/delivery.license -O /home/adminuser/delivery.license
git clone https://github.com/opscode-cookbooks/delivery-cluster.git /home/adminuser/delivery-cluster
mkdir /home/adminuser/delivery-cluster/environments
curl https://raw.githubusercontent.com/boobalana/bbrepo1/delivery-branch/testt.json -o /home/adminuser/test.json
sudo sed "s/10.7.1.4/chefServer.`hostname -f | cut -f 2-6 -d '.'`/g" /home/adminuser/test.json  > /home/adminuser/delivery-cluster/environments/testchef.json
wget https://raw.githubusercontent.com/boobalana/bbrepo1/delivery-branch/install.sh -O /home/adminuser/install.sh
wget https://raw.githubusercontent.com/boobalana/bbrepo1/delivery-branch/delivery_cred.sh -O /home/adminuser/delivery_cred.sh
chown -R adminuser:adminuser /home/adminuser
chmod 755 -R /home/adminuser
chmod 600 /home/adminuser/.ssh/id_rsa
chmod 644 /home/adminuser/.ssh/config