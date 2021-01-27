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
set -x
set -v

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "/tmp/sasinstall.env"
FORKS=5

echo "LoadbalancerDNS: ${PUBLIC_DNS_NAME}" >/tmp/ansible_vars.yaml
echo "AdminPassword: '{sas001}${sasPassword}'" >>/tmp/ansible_vars.yaml
echo "ExternalPassword: '${azurePassword}'" >>/tmp/ansible_vars.yaml
echo "HADOOP_VERSION: ${HADOOP_VERSION}" >>/tmp/ansible_vars.yaml
echo "HADOOP_HOME: '${HADOOP_HOME}'" >>/tmp/ansible_vars.yaml

pushd ${INSTALL_DIR}/ansible

export ANSIBLE_LOG_PATH=/tmp/step03_prereqs.log
ansible-playbook -i ${INVENTORY_FILE} -vvv step03_prereqs.yaml

export ANSIBLE_LOG_PATH=/tmp/step04_preinstall_sas.log
ansible-playbook -i ${INVENTORY_FILE} -vvv step04_preinstall_sas.yaml

# in order to get around the azure ci testing, we need
if [[ "$depot_uri" == "$DEPOT_DUMMY_FOR_QUICK_EXIT_VALUE" ]]; then
	popd
	echo "No license given. Doing infrastructure only install. SAS will not be installed."
	exit 0
fi

export ANSIBLE_LOG_PATH=/tmp/step05_download_mirror_and_licenses.log
ansible-playbook -i ${INVENTORY_FILE} \
	-e "DEPOT_DOWNLOAD_LOCATION=$depot_uri" \
	-e "LICENSE_DOWNLOAD_LOCATION=$license_file_uri" \
	-e "PLANFILE_DOWNLOAD_LOCATION=$planfile_uri" \
   -e "PRIMARY_USER=$INSTALL_USER" \
	-vvv step05_download_mirror_and_licenses.yaml

# Get the path to the sid file in the depot
SID_FILE=$(ls /sasshare/depot/sid_files)
echo "sid_file_name: $SID_FILE" >>/tmp/ansible_vars.yaml

# If no plan file is found after downloading mirror, use the default plan file provided by the quickstart
if [ ! -f "/sasshare/depot/plan.xml" ]; then
	cp /sas/install/plan.xml /sasshare/depot/plan.xml
fi

mkdir /sasshare/responsefiles
mkdir /sasshare/scripts
cp /sas/install/scripts/run_install_as_user.sh /sasshare/scripts/
mkdir /tmp/responsefiles

export ANSIBLE_LOG_PATH=/tmp/step06_update_responsefiles.log
ansible-playbook -i ${INVENTORY_FILE} -vvv step06_update_responsefiles.yaml

cp /tmp/responsefiles/* /sasshare/responsefiles

# Install hadoop
export ANSIBLE_LOG_PATH=/tmp/install_hadoop.log
ansible-playbook -i ${INVENTORY_FILE} -vvv install_hadoop.yaml

# Install TKGrid
export ANSIBLE_LOG_PATH=/tmp/install_tkgrid.log
ansible-playbook -i ${INVENTORY_FILE} -vvv install_tkgrid.yaml

# Install SAS Plug-in for hadoop
export ANSIBLE_LOG_PATH=/tmp/install_hadoop_plugin.log
ansible-playbook -i ${INVENTORY_FILE} -vvv install_hadoop_plugin.yaml

# Install SAS
export ANSIBLE_LOG_PATH=/tmp/step07_install_sas.log
ansible-playbook -i ${INVENTORY_FILE} -vvv step07_install_sas.yaml

# Stop the midtier SAS servers
export ANSIBLE_LOG_PATH=/tmp/step08_run_sas_servers.log
ansible-playbook -i ${INVENTORY_FILE} -vvv run_sas_servers.yaml --extra-vars "sas_hosts=midtier_servers sas_action=stop"

# Copy the loadbalancer cert to /sasshare and run the playbook to add it to all of the SAS installations
cp /sas/install/setup/ssl/loadbalancer.crt.pem /sasshare
export ANSIBLE_LOG_PATH=/tmp/step09_install_loadbalancer_cert.log
ansible-playbook -i ${INVENTORY_FILE} -vvv install_loadbalancer_cert.yaml

# Update the external URL connections for each SAS web app to use the SSL and loadbalancer DNS name
export ANSIBLE_LOG_PATH=/tmp/step10_setSASWebUrls.log
mkdir /tmp/sasfiles
mkdir /sasshare/sasfiles
ansible-playbook -i ${INVENTORY_FILE} -vvv create_metadata_update_scripts.yaml
cp /tmp/sasfiles/* /sasshare/sasfiles/
ansible-playbook -i ${INVENTORY_FILE} -vvv run_metadata_update_scripts.yaml

# Update the WIP Data Server to use the loadbalancer name, scheme and port for SASThemes_default
export ANSIBLE_LOG_PATH=/tmp/step11_update_wip_server.log
ansible-playbook -i ${INVENTORY_FILE} -vvv update_wip_server.yaml

# Update the midtier server configuration files with the loadbalancer name, scheme and port
export ANSIBLE_LOG_PATH=/tmp/step12_update_midtier_files.log
ansible-playbook -i ${INVENTORY_FILE} -vvv update_midtier_files.yaml

# Restart the SAS servers on all installations
export ANSIBLE_LOG_PATH=/tmp/step13_restart_servers.log
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=metadata_servers sas_action=restart"
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=va_controllers sas_action=restart"
ansible-playbook -i ${INVENTORY_FILE} -v run_sas_servers.yaml --extra-vars "sas_hosts=midtier_servers sas_action=restart"

popd
