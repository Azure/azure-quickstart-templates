#!/bin/bash

set -x

echo "starting augur_ui update"

sudo stop augur_ui

HOMEDIR="/home/$USER"

cd $HOMEDIR
ETHEREUM_HOST_RPC=`cat .eth_host_rpc`

####################
# Get contract addresses
####################
cd  augur-core/load_contracts
contracts="`python generate_gospel.py -j`"
contracts=$(echo $contracts | sed 's|\x22|\\\"|g')
contracts=$(echo $contracts | sed "s|[$'\t\r\n ']||g")
cd ../..


#####################
# Install latest augur ui
#####################
git clone https://github.com/AugurProject/augur.git
rm -rf ui
mkdir ui
cp -r augur/azure ui
rm -rf augur
find ui -type f -exec sed -i "s|\"{{ \$BUILD_AZURE_WSURL }}\"|null|g" {} \;
find ui -type f -exec sed -i "s|{{ \$BUILD_AZURE_LOCALNODE }}|$ETHEREUM_HOST_RPC|g" {} \;
find ui -type f -exec sed -i "s|\"{{ \$BUILD_AZURE_CONTRACTS }}\"|'$contracts'|g" {} \;
find ui -type f -exec sed -i "s|process.env.BUILD_AZURE|true|g" {} \;

sudo start augur_ui

echo "completed augur_ui install $$"