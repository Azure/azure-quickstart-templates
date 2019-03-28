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
. "/sas/install/env.ini"
FORKS=5

INVENTORY_FILE="inventory.ini"

export ANSIBLE_STDOUT_CALLBACK=debug
export ANSIBLE_ANY_ERRORS_FATAL=True

cd $ScriptDirectory/../playbooks
time ansible-playbook -f $FORKS -i $INVENTORY_FILE -v post.deployment.yml -e "cas_virtual_host=$PUBLIC_DNS_NAME"
ret="$?"
if [ "$ret" -ne "0" ]; then
    exit $ret
fi