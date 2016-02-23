#!/bin/bash
set -x

date
ps axjf

##################################################################################################
# Set the variables.                                                                             #
##################################################################################################
NPROC=$(nproc)
USER_NAME=$1

##################################################################################################
# Update Ubuntu and install prerequisites for running BitShares                                  #
##################################################################################################
time apt-get -y update
time apt-get -y install ntp g++ git make cmake libbz2-dev libdb++-dev libdb-dev libssl-dev \
                        openssl libreadline-dev autoconf libtool libboost-all-dev

##################################################################################################
# Build BitShares from source                                                                    #
##################################################################################################
cd /usr/local
time git clone https://github.com/bitshares/bitshares-core.git
cd bitshares-core/
time git submodule update --init --recursive
time cmake -DCMAKE_BUILD_TYPE=Release .
time make -j$NPROC

cp /usr/local/bitshares-core/programs/witness_node/witness_node /usr/bin/bitshares_witness_node
cp /usr/local/bitshares-core/programs/cli_wallet/cli_wallet /usr/bin/bitshares_cli_wallet

##################################################################################################
# Configure bitshares service. Enable it to start on boot.                                       #
##################################################################################################
cat >/lib/systemd/system/bitshares.service <<EOL
[Unit]
Description=Job that runs bitshares daemon
[Service]
Type=simple
Environment=statedir=/home/$USER_NAME/bitshares/witness_node
ExecStartPre=/bin/mkdir -p /home/$USER_NAME/bitshares/witness_node
ExecStart=/usr/bin/bitshares_witness_node --rpc-endpoint=127.0.0.1:8090 -d /home/$USER_NAME/bitshares/witness_node
[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable bitshares

##################################################################################################
# Start the BitShares service to allow it to create the default configuration file. Stop the     #
# service, modify the config.ini file, then restart the service with the new settings applied.   #
##################################################################################################
service bitshares start
wait 5
sed -i 's/level=debug/level=info/g' /home/$USER_NAME/bitshares/witness_node/config.ini
service bitshares stop
wait 5
service bitshares start

##################################################################################################
# Connect to host via SSH, then start cli wallet:                                                #
# $sudo /usr/bin/cli_wallet --wallet-file=/usr/local/bitshares-core/programs/cli-wallet/wallet.json #
# >set_password use_a_secure_password_but_check_your_shoulder_as_it_will_be_displayed_on_screen  #
# >ctrl-d [will save the wallet and exit the client]                                             #
# $nano /usr/local/bitshares-core/programs/cli-wallet/wallet.json                                   #
# Learn more: http://docs.bitshares.eu                                                           #
##################################################################################################

