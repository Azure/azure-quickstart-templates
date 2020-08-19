#!/bin/bash
###
# So, the purpose of this file is to do the actual install of sas, mostly using ansible as the driving engine. It expects to be a long running process on the box and not to need to be interupted. In case of an error, it should exit uncleanly.
# This expects to be run by the install_runner_base.sh, which is responsible for writing the logfiles out and for maintaining the return file (which is getting checked for the return code of the process).
#
# So you ask, why do all this? Good question, and the answer is that the sas install process can take over an hour, but the azure extension object in azure resource manager times
#  out after about an hour. To fix our way around this, we run several extensions in series that all monitor an asyncronous process (this process in fact.) Adding extra wrapper
#  files lets this bash be a rather simple and strait forward file with everything being taken care of in the background.
#
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

echo "AdminPassword: '{sas001}${sasPassword}'" >/tmp/ansible_vars.yaml
echo "ExternalPassword: '${azurePassword}'" >>/tmp/ansible_vars.yaml

INVENTORY_FILE="inventory.ini"
cd $ANSIBLE_DIR
ansible-playbook -i ${INVENTORY_FILE} -v step02_install_os_updates.yaml

# in order to get around the azure ci testing, we need
if [[ "$depot_uri" == "$DEPOT_DUMMY_FOR_QUICK_EXIT_VALUE" ]]; then
	echo "No license given. Doing infrastructure only install. SAS will not be installed."
	exit 0
fi

ansible-playbook -i ${INVENTORY_FILE} -vvv step03_prereqs.yaml

ansible-playbook -i ${INVENTORY_FILE} \
	-e "DEPOT_DOWNLOAD_LOCATION=$depot_uri" \
	-e "LICENCE_DOWNLOAD_LOCATION=$license_file_uri" \
	-e "PLANFILE_DOWNLOAD_LOCATION=$planfile_uri" \
	-vvv step04_download_mirror_and_licenses.yaml

# Get the path to the sid file in the depot
SID_FILE=$(ls /sasshare/depot/sid_files)
echo "sid_file_name: $SID_FILE" >>/tmp/ansible_vars.yaml

ansible-playbook -i ${INVENTORY_FILE} -vvv step05_preinstall_sas.yaml

ansible-playbook -i ${INVENTORY_FILE} -vvv step06_install_sas.yaml
