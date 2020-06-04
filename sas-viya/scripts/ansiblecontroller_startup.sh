#!/bin/bash
if [ -e "$HOME/.profile" ]; then
	. $HOME/.profile
fi
if [ -e "$HOME/.bash_profile" ]; then
	. $HOME/.bash_profile
fi
#set -x
#set -v
ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
environmentLocation="/sas/install/env.ini"

echo "$@" >> /tmp/commands.log
mkdir -p "/sas/install"

. "$environmentLocation"
chmod 700 "$INSTALL_DIR"
chown $INSTALL_USER "/sas/install"
set -e
if [[ -z "$SCRIPT_PHASE" ]]; then
SCRIPT_PHASE="$1"
fi
if [[ "$SCRIPT_PHASE" -eq "1" ]]; then
cat << EOF > "$environmentLocation"
# export SCRIPT_PHASE="$1"
export https_location="$2"
export https_sas_key="$3"
export license_file_uri="$4"
export INSTALL_USER="$5"
export ADMINPASS="$6"
export USERPASS="$7"
export PRIVATE_SUBNET_IPRANGE="$8"
export PUBLIC_DNS_NAME="$9"
export MIRROR_HTTP="${10}"
export azure_storage_account="${11}"
export azure_storage_files_share="${12}"
export azure_storage_files_password="${13}"
export CASInstanceCount="${14}"
export DUMMY_LICENSE_STRING="${15}"

export LOGS_DIR=/var/log/sas/install
export DIRECTORY_NFS_SHARE="/mnt/\${azure_storage_files_share}"
export NFS_SHARE_DIR="/mnt/\${azure_storage_files_share}"
export INSTALL_DIR="/sas/install"
export ANSIBLE_KEY_DIR="\${DIRECTORY_NFS_SHARE}/setup/ansible_key"
export READINESS_FLAGS_DIR="\${DIRECTORY_NFS_SHARE}/setup/readiness_flags"
export DIRECTORY_MIRROR="/mnt/resource/mirror"
export REMOTE_DIRECTORY_MIRROR="\${DIRECTORY_MIRROR}"
export DIRECTORY_LICENSE_FILE="\${INSTALL_DIR}/license"
export DIRECTORY_SSL_JSON_FILE="\${INSTALL_DIR}/setup/ssl"
export DIRECTORY_ANSIBLE_INVENTORIES="\${DIRECTORY_NFS_SHARE}/setup/ansible/inventory"
export DIRECTORY_ANSIBLE_GROUPS="\${DIRECTORY_NFS_SHARE}/setup/ansible/groups"
export FILE_LICENSE_FILE="\${DIRECTORY_LICENSE_FILE}/license_file.zip"
export CAS_URI_FILE="\${DIRECTORY_LICENSE_FILE}/cas_size.txt"
export FILE_SSL_JSON_FILE="\${DIRECTORY_SSL_JSON_FILE}/loadbalancer.pfx.json"
export FILE_CA_B64_FILE="\${DIRECTORY_SSL_JSON_FILE}/sas_certificate_all.crt.b64.txt"
export ORCHESTRATION_DIRECTORY="\${INSTALL_DIR}/setup/orchestration"
export VIRK_CLONE_DIRECTORY="\${ORCHESTRATION_DIRECTORY}/sas_viya_playbook/viya-ark"
export CODE_DIRECTORY="\${INSTALL_DIR}"
export ANSIBLE_SSH_RETRIES=10
export UTILITIES_DIR="\${INSTALL_DIR}/bin"

export TOUCHPOINT_PREREQUISITES="/tmp/prerequisites.touch"
export TOUCHPOINT_PREORCHESTRATION="/tmp/preorchestration.touch"



EOF
. "$environmentLocation"

	echo "running ansible prerequisites install"
	${ScriptDirectory}/ansiblecontroller_prereqs.sh
	su $INSTALL_USER -c	"${CODE_DIRECTORY}/scripts/wrapper_01_prereq.sh"
# here we return the sizing for the cas controller

# here we return the ssl certificate for the system (has to be done in 2 pieces because we only get to return 4096 charectors)
elif [[ "$SCRIPT_PHASE" -eq "3" ]]; then
	cat "${FILE_SSL_JSON_FILE}.1" |tr -d '\n'
elif [[ "$SCRIPT_PHASE" -eq "4" ]]; then
	cat "${FILE_SSL_JSON_FILE}.2" |tr -d '\n'
elif [[ "$SCRIPT_PHASE" -eq "5" ]]; then
	su $INSTALL_USER -c	"${CODE_DIRECTORY}/scripts/wrapper_02_preorchestration.sh"
elif [[ "$SCRIPT_PHASE" -eq "6" ]]; then
    cat "$FILE_CA_B64_FILE"|tr -d '\n'
elif [[ "$SCRIPT_PHASE" -eq "7" ]]; then
	echo "Starting/Continuing Actual Install"
	su $INSTALL_USER -c	"${CODE_DIRECTORY}/scripts/wrapper_03_orchestration.sh"
elif [[ "$SCRIPT_PHASE" -eq "8" ]]; then
	echo "Finishing Actual Install"
	su $INSTALL_USER -c	"${CODE_DIRECTORY}/scripts/wrapper_04_final.sh"
elif [[ "$SCRIPT_PHASE" -eq "9" ]]; then
	cat "${CAS_URI_FILE}" |tr -d '\n'
fi
