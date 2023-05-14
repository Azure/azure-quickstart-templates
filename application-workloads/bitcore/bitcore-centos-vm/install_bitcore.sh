#!/bin/bash
set -x
echo "Initializing Bitcore installation"

#############
# Parameters
#############
AZUREUSER=$1
HOME="/home/$AZUREUSER"
echo "User: $AZUREUSER"
echo "User home dir: $HOME"

yum -y install epel-release
yum -y install npm git curl which xz tar findutils
npm install -g n
n 4.2.4
cat >/etc/systemd/system/bitcored.service <<EOL
[Unit]
Description=bitcored.service
After=network.target

[Service]
Type=simple
User=$AZUREUSER
ExecStart=/usr/local/bin/bitcored
ExecReload=/bin/kill -2 \$MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.agent
EOL
/bin/bash -l -c "export PATH=/usr/local/bin:\$PATH; export HOME=$HOME; npm install -g bitcore"
/bin/bash -l -c "parted -s /dev/sdc mklabel gpt unit s mkpart primary `parted -s /dev/sdc mklabel gpt unit s print free | grep 'Free Space' | tail -n 1 | awk '{print $1}'` `parted -s /dev/sdc mklabel gpt unit s print free | grep 'Free Space' | tail -n 1 | awk '{print $2}'` && mkfs.ext4 /dev/sdc1 && mkdir $HOME/.bitcore && mount /dev/sdc1 $HOME/.bitcore"
/bin/bash -l -c "chown -R $AZUREUSER $HOME/.bitcore"
systemctl start bitcored
echo "Completed Bitcore install $$"
