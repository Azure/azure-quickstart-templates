#!/bin/bash

# print commands and arguments as they are executed
set -x;

#############
# Parameters
#############
# Validate that all arguments are supplied
if [ $# -lt 7 ]; then echo "Incomplete parameters supplied. Exiting"; exit 1; fi

AZUREUSER=$1;
ARTIFACTS_URL_PREFIX=$4

#############
# Get the script for running as Azure user
#############
cd "/home/$AZUREUSER";
sudo -u $AZUREUSER sh -c "wget -N ${ARTIFACTS_URL_PREFIX}/scripts/configure-geth-azureuser.sh";

sudo -u $AZUREUSER sh /home/$AZUREUSER/configure-geth-azureuser.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12;
