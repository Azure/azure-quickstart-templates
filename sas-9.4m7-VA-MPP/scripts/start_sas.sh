#!/bin/bash
###
# So, the purpose of this file is start all components on all sas tiers sas, using <SAS_HOME>/config/Lev1/sas.servers start
# input action - start sas servers
#
# By default, this script only starts the sas servers
#
# If the "hard" parameter is specified, it will try to start the VMs before starting the sas servers
#
###
HARD=$1

if [ -e "$HOME/.profile" ]; then
	. $HOME/.profile
fi
if [ -e "$HOME/.bash_profile" ]; then
	. $HOME/.bash_profile
fi
#set -x
#set -v
set -e

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 . "/tmp/sasinstall.env"
FORKS=5

INVENTORY_FILE="inventory.ini"
pushd $ANSIBLE_DIR


if [[ "${HARD}" == "hard" ]]; then

#
# Verify that the user has logged in to Azure
#
        AZ_STATUS=$(/usr/local/bin/az account list)

	if [[ ${#AZ_STATUS} -le 2 ]]; then
	  echo "You must authenticate with Azure before running this command. Run"
	  echo ""
	  echo "   /usr/local/bin/az login --use-device-code"
	  echo ""
	  echo "to authenticate."
	  echo ""
	  echo "Verify that the current subscription matches the subscription for this resource group."
	  echo "If they do not match, run"
	  echo ""
	  echo "   /usr/local/bin/az account set --subscription [subscription-name-or-id]"
	  echo ""
	  echo "to set the current subscription."
	  exit 0
	fi

#
# Get a list of the VMs in the resource group
#
	VMLIST=( $(/usr/local/bin/az vm list -g "${azure_resource_group}" --query "[].name" -o tsv) )

#
# Start the VMs in the list EXCEPT for jumpvm
#
	for v in ${VMLIST[@]}; do
	    if [[ $v != "jumpvm" ]]; then
	      echo "Starting ${v}"
	      /usr/local/bin/az vm start --resource-group "${azure_resource_group}" --name "${v}"
	    fi
	done

#
# Wait for all the VMs to get online
#

	export ANSIBLE_LOG_PATH=/tmp/wait_for_servers.log
	ansible-playbook -i ${INVENTORY_FILE} -v wait_for_servers.yaml
fi

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
# Only start Hadoop on HARD start, otherwise it's already running
if [[ "${HARD}" == "hard" ]]; then
    ansible-playbook -i ${INVENTORY_FILE} -v run_hadoop_servers.yaml --extra-vars "hadoop_hosts=va_controllers hadoop_action=start"
fi

popd

if (( $(grep -c 'SAS_ERROR:'  "/tmp/${LOG_FILE}") != 0 )); then
    exit 1
fi

exit 0
