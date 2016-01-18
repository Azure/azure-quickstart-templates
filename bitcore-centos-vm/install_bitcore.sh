#!/bin/bash
set -x
echo "Initializing Bitcore installation"

#############
# Parameters
#############
AZUREUSER=$1
HOMEDIR="/home/$AZUREUSER"
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"

yum -y install git curl which xz tar findutils
groupadd $AZUREUSER
useradd $AZUREUSER -m -s /bin/bash -g $AZUREUSER
cat >/etc/systemd/system/bitcored.conf <<"EOL"
[Unit]
Description=bitcored.service
After=network.target

[Service]
Type=simple
User=AZUREUSER
Environment="PATH=$PATH:/home/bitcore/.nvm/versions/node/v4.2.4/bin"
ExecStart=/home/bitcore/.nvm/versions/node/v4.2.4/bin/bitcored
ExecReload=/bin/kill -2 $MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.agent
EOL
sed -i "/AZUREUSER/$ASUREUSER/g" "/etc/systemd/system/bitcored.conf"
sudo su - $AZUREUSER
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
/bin/bash -l -c "nvm install v4 && nvm alias default v4"
/bin/bash -l -c "npm install bitcore -g"
exit
systemctl start bitcored
echo "Completed Bitcore install $$"

