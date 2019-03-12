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

cat << EOF > "$environmentLocation"
export SCRIPT_PHASE="$1"
export https_location="$2"
export https_sas_key="$3"
export license_file_uri="$4"
export PRIMARY_USER="$5"
export ADMINPASS="$6"
export USERPASS="$7"
export PRIVATE_SUBNET_IPRANGE="$8"
export PUBLIC_DNS_NAME="$9"
export MIRROR_HTTP="${10}"
export azure_storage_account="${11}"
export azure_storage_files_share="${12}"
export azure_storage_files_password="${13}"

export DIRECTORY_NFS_SHARE="/mnt/\${azure_storage_files_share}"
export REMOTE_DIRECTORY_NFS_MOUNT="/mnt/\${azure_storage_files_share}"
export SAS_INSTALL_SRC_DIRECTORY="/sas/install"
export DIRECTORY_ANSIBLE_KEYS="\${DIRECTORY_NFS_SHARE}/setup/ansible_key"
export DIRECTORY_READYNESS_FLAGS="\${DIRECTORY_NFS_SHARE}/setup/readiness_flags"
export DIRECTORY_MIRROR="/mnt/resource/mirror"
export REMOTE_DIRECTORY_MIRROR="\${DIRECTORY_MIRROR}"
export DIRECTORY_LICENSE_FILE="\${SAS_INSTALL_SRC_DIRECTORY}/license"
export DIRECTORY_SSL_JSON_FILE="\${SAS_INSTALL_SRC_DIRECTORY}/setup/ssl"
export DIRECTORY_ANSIBLE_INVENTORIES="\${DIRECTORY_NFS_SHARE}/setup/ansible/inventory"
export DIRECTORY_ANSIBLE_GROUPS="\${DIRECTORY_NFS_SHARE}/setup/ansible/groups"
export FILE_LICENSE_FILE="\${DIRECTORY_LICENSE_FILE}/license_file.zip"
export CAS_SIZING_FILE="\${DIRECTORY_LICENSE_FILE}/cas_size.txt"
export FILE_SSL_JSON_FILE="\${DIRECTORY_SSL_JSON_FILE}/loadbalancer.pfx.json"
export FILE_CA_B64_FILE="\${DIRECTORY_SSL_JSON_FILE}/sas_certificate_all.crt.b64.txt"
export ORCHESTRATION_DIRECTORY="\${SAS_INSTALL_SRC_DIRECTORY}/setup/orchestration"
export VIRK_CLONE_DIRECTORY="\${ORCHESTRATION_DIRECTORY}/sas_viya_playbook/virk"
export CODE_DIRECTORY="\${SAS_INSTALL_SRC_DIRECTORY}/code"
export ANSIBLE_SSH_RETRIES=10
EOF
. "$environmentLocation"
chmod 700 "/sas/install"
chown $PRIMARY_USER "/sas/install"
#./bastion_bootstrap.sh --enable false
if [ "$SCRIPT_PHASE" -eq "1" ]; then
	echo "running ansible prerequisites install"
	${ScriptDirectory}/ansiblecontroller_prereqs.sh
# here we return the sizing for the cas controller
elif [ "$SCRIPT_PHASE" -eq "2" ]; then
	cat "${CAS_SIZING_FILE}" |tr -d '\n'
# here we return the ssl certificate for the system (has to be done in 2 pieces because we only get to return 4096 charectors)
elif [ "$SCRIPT_PHASE" -eq "3" ]; then
	cat "${FILE_SSL_JSON_FILE}.1" |tr -d '\n'
elif [ "$SCRIPT_PHASE" -eq "4" ]; then
	cat "${FILE_SSL_JSON_FILE}.2" |tr -d '\n'
elif [ "$SCRIPT_PHASE" -eq "5" ]; then
	echo "waiting for sync with client servers"
	${CODE_DIRECTORY}/scripts/ansiblecontroller_waitforsync.sh
	ret="$?"
    if [ "$ret" -ne "0" ]; then
        echo "Timed out after 30 min waiting for Services and Controller to mount shared folder and announce readyness."
        exit $ret
    fi
	echo "Install Prep"
	su $PRIMARY_USER -c	"${CODE_DIRECTORY}/scripts/install_pre_orchestration.sh"
	ret="$?"
    if [ "$ret" -ne "0" ]; then
        exit $ret
    fi
elif [ "$SCRIPT_PHASE" -eq "6" ]; then
    cat "$FILE_CA_B64_FILE"|tr -d '\n'
elif [ "$SCRIPT_PHASE" -eq "7" ]; then
	echo "Starting/Continuing Actual Install"
	su $PRIMARY_USER -c "${CODE_DIRECTORY}/scripts/install_run_orchestration_wrapper.sh"
	ret="$?"
    if [ "$ret" -ne "0" ]; then
        exit $ret
    fi
elif [ "$SCRIPT_PHASE" -eq "8" ]; then
	echo "Finishing Actual Install"
	su $PRIMARY_USER -c "${CODE_DIRECTORY}/scripts/install_run_orchestration_wrapper.sh"
	ret="$?"
    if [ "$ret" -ne "0" ]; then
        exit $ret
    fi
fi
