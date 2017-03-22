#!/bin/bash
set -x
echo "Initializing Nylas Open Source Sync Engine installation"

#############
# Parameters
#############
AZUREUSER=$1
HOME="/home/$AZUREUSER"
echo "User: $AZUREUSER"
echo "User home dir: $HOME"

# update os
apt-get update

# install git
apt-get install -y git

# clone the sync engine repo
cd $HOME

git clone https://github.com/singhkay/sync-engine.git
/bin/bash -l -c "chown -R $AZUREUSER $HOME/sync-engine"

cd $HOME/sync-engine/

# kick off the setup script
chmod +x ./setup.sh
sudo ./setup.sh
chown -R $AZUREUSER /etc/inboxapp

runuser -l $AZUREUSER -c "nohup /home/$AZUREUSER/sync-engine/bin/inbox-start &"
