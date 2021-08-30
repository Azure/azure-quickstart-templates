#!/bin/bash
###
# So, the purpose of this file is stop all components on all sas tiers sas, using <SAS_HOME>/config/Lev1/sas.servers stop
# input action - stop sas servers
#
# By default, this script only stops the sas servers
#
# If the "hard" parameter is used, it will also stop the VMs after stopping the sas servers
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

# echo "AdminPassword: '{sas001}${sasPassword}'" >/tmp/ansible_vars.yaml
# echo "ExternalPassword: '${azurePassword}'" >>/tmp/ansible_vars.yaml

INVENTORY_FILE="inventory.ini"
cd $ANSIBLE_DIR
LOG_FILE="stop_sas.log"

if [[ -e /tmp/${LOG_FILE} ]]; then
    rm -rf  /tmp/${LOG_FILE}
fi
# ansible-playbook -i ${INVENTORY_FILE} -vvv stop_sas_servers.yaml --extra-vars "hosts=<host_group> sas_action=stop"
# ansible-playbook -i inventory.ini run_sas_servers.yaml.yaml --extra-vars "hosts=va_workers"
# 1.	Mid-tier cluster node(s) - there may be zero or more of these  -  midtier_servers
# 2.	Mid-tier                                                       -  midtier_servers
# 3.	VA compute worker - there may be zero or more of these         -  va_workers
# 4.	VA compute main                                                -  va-controllers
# 5.	Metadata cluster node(s) - there may be zero or more of these  -  metadata_servers
# 6.	Metadata                                                       -  metadata_servers
export ANSIBLE_LOG_PATH=/tmp/${LOG_FILE}
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=midtier_servers sas_action=stop"
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=va_workers sas_action=stop"
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=va_controllers sas_action=stop"
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=metadata_servers sas_action=stop"
#ansible-playbook -i ${INVENTORY_FILE} -v run_hadoop_servers.yaml --extra-vars "hadoop_hosts=va_controllers hadoop_action=stop"

COUNT=$(grep -c 'SAS_ERROR:'  "/tmp/${LOG_FILE}")
if (( $COUNT != 0 )); then
  if [[ $(grep -c 'sas.servers NOT found' "/tmp/${LOG_FILE}") != $COUNT ]]; then
    exit 1
  fi
fi

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
# Stop the running VMs
#

# Get a list of the VMs in this resource group - azure_resource_group is a variable from sasinstall.env
	VMLIST=( $(/usr/local/bin/az vm list -g "${azure_resource_group}" --query "[].name" -o tsv) )

# Iterate through the VM list and stop all VMs EXCEPT jumpvm
	for v in ${VMLIST[@]}; do
	    if [[ $v != "jumpvm" ]]; then
	      echo "Stopping ${v}"
	      /usr/local/bin/az vm stop --resource-group "${azure_resource_group}" --name "${v}"
	    fi
	done
fi

exit 0
