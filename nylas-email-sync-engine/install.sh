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
/bin/bash -l -c "chmod +x ./setup.sh"
/bin/bash -l -c "sudo ./setup.sh"

/bin/bash -l -c "nohup bin/inbox-start &"
