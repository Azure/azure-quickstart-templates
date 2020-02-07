#!/bin/bash
if [ -e "$HOME/.profile" ]; then
	. $HOME/.profile
fi
if [ -e "$HOME/.bash_profile" ]; then
	. $HOME/.bash_profile
fi
set -x
set -v
ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "/sas/install/env.ini"
FORKS=5

INVENTORY_FILE="inventory.ini"

export ANSIBLE_STDOUT_CALLBACK=debug
export ANSIBLE_ANY_ERRORS_FATAL=True

cd $ScriptDirectory/../playbooks


time ansible-playbook -i $INVENTORY_FILE -v create_main_inventory.yml -e CODE_DIRECTORY="${CODE_DIRECTORY}" -e GROUPS_DIRECTORY="${DIRECTORY_ANSIBLE_GROUPS}" -e INVENTORIES_DIRECTORY="${DIRECTORY_ANSIBLE_INVENTORIES}"
ret="$?"
if [ "$ret" -ne "0" ]; then
    exit $ret
fi

time ansible-playbook -f $FORKS -i $INVENTORY_FILE -v pre.deployment.yml -e VIRK_CLONE_DIRECTORY="$VIRK_CLONE_DIRECTORY" -e ORCHESTRATION_DIRECTORY="$ORCHESTRATION_DIRECTORY" -e "sasboot_pw='$ADMINPASS'" -e "OLCROOTPW='$ADMINPASS' OLCUSERPW='$USERPASS'" -e LOCAL_DIRECTORY_MIRROR="${DIRECTORY_MIRROR}" -e REMOTE_DIRECTORY_MIRROR="${REMOTE_DIRECTORY_MIRROR}" -e MIRROR_HTTP="${MIRROR_HTTP}" -e LICENSE_FILE="${FILE_LICENSE_FILE}" -e SSL_WORKING_FOLDER="${DIRECTORY_SSL_JSON_FILE}" -e CODE_DIRECTORY="${CODE_DIRECTORY}"
ret="$?"
if [ "$ret" -ne "0" ]; then
    exit $ret
fi




