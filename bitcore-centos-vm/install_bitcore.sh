#!/bin/bash
yum -y install git curl which xz tar findutils
groupadd bitcore
useradd bitcore -m -s /bin/bash -g bitcore
cat >/etc/systemd/system/bitcored.conf <<"EOL"
[Unit]
Description=bitcored.service
After=network.target

[Service]
Type=simple
User=bitcore
Environment="PATH=$PATH:/home/bitcore/.nvm/versions/node/v4.2.4/bin"
ExecStart=/home/bitcore/.nvm/versions/node/v4.2.4/bin/bitcored
ExecReload=/bin/kill -2 $MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.agent
EOL
sudo su - bitcore
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
/bin/bash -l -c "nvm install v4 && nvm alias default v4"
/bin/bash -l -c "npm install bitcore -g"
exit
systemctl start bitcored
