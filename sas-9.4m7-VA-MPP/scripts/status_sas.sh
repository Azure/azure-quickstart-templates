#!/bin/bash
###
# So, the purpose of this file is to get status of all components on all sas tiers, using <SAS_HOME>/config/Lev1/sas.servers status
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

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 . "/tmp/sasinstall.env"
FORKS=5

INVENTORY_FILE="inventory.ini"
cd $ANSIBLE_DIR
LOG_FILE="status_sas.log"

if [[ -e /tmp/${LOG_FILE} ]]; then    
    rm -rf  /tmp/${LOG_FILE}
fi

export ANSIBLE_LOG_PATH=/tmp/${LOG_FILE}
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=metadata_servers sas_action=status"
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=va_controllers sas_action=status"
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=va_workers sas_action=status"
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=midtier_servers sas_action=status"

if (( $(grep -c 'SAS_ERROR:'  "/tmp/${LOG_FILE}") != 0 )); then
    exit 1   
fi

exit 0
