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

#the file into which the return code will be written
RETURN_FILE="$1"


# sometimes there are ssh connection errors (53) during the install
# this function allows to retry N times
function try () {
  # allow up to N attempts of a command
  # syntax: try N [command]
  RC=1; count=1; max_count=$1; shift
  until  [ $count -gt "$max_count" ]
  do
    "$@" && RC=0 && break || let count=count+1
  done
  return $RC
}
start_time="$(date -u +%s)"

export ANSIBLE_STDOUT_CALLBACK=debug
export ANSIBLE_ANY_ERRORS_FATAL=True
cd $ScriptDirectory/../playbooks
if [ -n "$USERPASS" ]; then
	echo "$(date) Install and set up OpenLDAP (see deployment-openldap.log)"

	time ansible-playbook -v -f $FORKS "${CODE_DIRECTORY}/openldap/openldapsetup.yml" -i $INVENTORY_FILE -e "OLCROOTPW='$ADMINPASS' OLCUSERPW='$USERPASS'"
	ret="$?"
	if [ "$ret" -ne "0" ]; then
		exit $ret
	fi
#	rm -f "${ORCHESTRATION_DIRECTORY}/sas_viya_playbook/roles/consul/files/sitedefault.yml"
#	cp "${CODE_DIRECTORY}/openldap/sitedefault.yml" "${ORCHESTRATION_DIRECTORY}/sas_viya_playbook/roles/consul/files/"
fi

openldap_installed_time="$(date -u +%s)"

time ansible-playbook -f $FORKS -i $INVENTORY_FILE -v at.deployment.yml -e VIRK_CLONE_DIRECTORY="$VIRK_CLONE_DIRECTORY" -e ORCHESTRATION_DIRECTORY="$ORCHESTRATION_DIRECTORY" -e "sasboot_pw='$ADMINPASS'" -e "OLCROOTPW='$ADMINPASS' OLCUSERPW='$USERPASS'" -e LOCAL_DIRECTORY_MIRROR="${DIRECTORY_MIRROR}" -e REMOTE_DIRECTORY_MIRROR="${REMOTE_DIRECTORY_MIRROR}" -e MIRROR_HTTP="${MIRROR_HTTP}" -e LICENSE_FILE="${FILE_LICENSE_FILE}" -e SSL_WORKING_FOLDER="${DIRECTORY_SSL_JSON_FILE}" -e CODE_DIRECTORY="${CODE_DIRECTORY}"
ret="$?"
if [ "$ret" -ne "0" ]; then
    exit $ret
fi
download_mirrors_and_orchestration_time="$(date -u +%s)"

#if [ -n "$USERPASS" ]; then
#    rm -f "${ORCHESTRATION_DIRECTORY}/sas_viya_playbook/roles/consul/files/sitedefault.yml"
#	cp "${CODE_DIRECTORY}/openldap/sitedefault.yml" "${ORCHESTRATION_DIRECTORY}/sas_viya_playbook/roles/consul/files/"
#fi

time ansible-playbook -v -f $FORKS "${VIRK_CLONE_DIRECTORY}/playbooks/pre-install-playbook/viya_pre_install_playbook.yml" -i "$ORCHESTRATION_DIRECTORY/sas_viya_playbook/inventory.ini" --skip-tags skipmemfail,skipcoresfail,skipstoragefail,skipnicssfail,bandwidth -e 'use_pause=false'
ret="$?"
if [ "$ret" -ne "0" ]; then
    exit $ret
fi
ran_virk_time="$(date -u +%s)"


sudo chown -R $USER "${ORCHESTRATION_DIRECTORY}"
cd "${ORCHESTRATION_DIRECTORY}/sas_viya_playbook"
ansible-playbook site.yml
ret="$?"
if [ ! -z "$RETURN_FILE" ]; then
    echo "$ret" > "$RETURN_FILE"
fi
if [ "$ret" -ne "0" ]; then
    exit $ret
fi
finished_time="$(date -u +%s)"

cd $ScriptDirectory/../playbooks
time ansible-playbook -f $FORKS -i $INVENTORY_FILE -v post.deployment.yml -e "cas_virtual_host=$PUBLIC_DNS_NAME"
ret="$?"
if [ "$ret" -ne "0" ]; then
    exit $ret
fi
finished_post_orchestration_time="$(date -u +%s)"

elapsed="$(($openldap_installed_time-$start_time))"
printf 'Time to install openldap: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
elapsed="$(($download_mirrors_and_orchestration_time-$openldap_installed_time))"
printf 'Time to setup mirror and orchestration: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
elapsed="$(($ran_virk_time-$download_mirrors_and_orchestration_time))"
printf 'Time to run virk playbook: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
elapsed="$(($finished_time-$ran_virk_time))"
printf 'Time to run sas installer: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
elapsed="$(($finished_post_orchestration_time-$finished_time))"
printf 'Time to run post configuration: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
elapsed="$(($finished_post_orchestration_time-$start_time))"
printf 'Total time: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))