#!/bin/bash
yum -y install git curl which xz tar findutils
groupadd bitcore
useradd bitcore -m -s /bin/bash -g bitcore
sudo su - bitcore
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
/bin/bash -l -c "nvm install v4 && nvm alias default v4"
/bin/bash -l -c "npm install bitcore -g"
bitcored
