#!/bin/bash
###
# So, the purpose of this file is start all components on all sas tiers sas, using <SAS_HOME>/config/Lev1/sas.servers start
# input action - start sas servers
#
###
if [ -e "$HOME/.profile" ]; then
	. $HOME/.profile
fi
if [ -e "$HOME/.bash_profile" ]; then
	. $HOME/.bash_profile
fi
#set -x
#set -v
set -e

#
# Verify that the user has logged in to Azure
#

AZ_STATUS=$(/opt/rh/rh-python36/root/usr/bin/az account list) 

if [[ ${#AZ_STATUS} -le 2 ]]; then
  echo "You must authenticate with Azure before running this command. Run"
  echo ""
  echo "   /opt/rh/rh-python36/root/usr/bin/az login --use-device-code"
  echo ""
  echo "to authenticate."
  echo ""
  echo "Verify that the current subscription matches the subscription for this resource group."
  echo "If they do not match, run"
  echo ""
  echo "   /opt/rh/rh-python36/root/usr/bin/az account set --subcription [subscription-name-or-id]"
  echo ""
  echo "to set the current subscription."
  exit 0
fi

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 . "/tmp/sasinstall.env"
FORKS=5

#
# Get a list of the VMs in the resource group
#
VMLIST=( $(/opt/rh/rh-python36/root/usr/bin/az vm list -g "${azure_resource_group}" --query "[].name" -o tsv) )

#
# Start the VMs in the list EXCEPT for jumpvm
#
for v in ${VMLIST[@]}; do
    if [[ $v != "jumpvm" ]]; then
      echo "Starting ${v}"
      /opt/rh/rh-python36/root/usr/bin/az vm start --resource-group "${azure_resource_group}" --name "${v}"
    fi
done

INVENTORY_FILE="inventory.ini"
cd $ANSIBLE_DIR

#
# Wait for all the VMs to get online
#

export ANSIBLE_LOG_PATH=/tmp/swait_for_servers.log
ansible-playbook -i ${INVENTORY_FILE} -v step01_wait_for_servers.yaml

LOG_FILE="start_sas.log"

if [[ -e /tmp/${LOG_FILE} ]]; then    
    rm -rf  /tmp/${LOG_FILE}
fi 

# Start order of sas servers on nodes
# 1.	Metadata                                                       -  metadata_servers
# 2.	Metadata cluster node(s) - there may be zero or more of these  -  metadata_servers
# 3.	VA compute main                                                -  va-controllers
# 4.	VA compute worker - there may be zero or more of these         -  va_workers
# 5.	Mid-tier                                                       -  midtier_servers 
# 6.	Mid-tier cluster node(s) - there may be zero or more of these  -  midtier_servers
export ANSIBLE_LOG_PATH=/tmp/${LOG_FILE}
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=metadata_servers sas_action=start"
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=va_controllers sas_action=start"
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=va_workers sas_action=start"
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=midtier_servers sas_action=start"

if (( $(grep -c 'SAS_ERROR:'  "/tmp/${LOG_FILE}") != 0 )); then
    exit 1   
fi

exit 0

