#!/bin/bash
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
. "/sas/install/env.ini"
FORKS=5

INVENTORY_FILE="inventory.ini"

#the file into which the return code will be written
RETURN_FILE="$1"


# sometimes there are ssh connection errors (53) during the install
# this function allows to retry N times
#function try () {
#  # allow up to N attempts of a command
#  # syntax: try N [command]
#  RC=1; count=1; max_count=$1; shift
#  until  [ $count -gt "$max_count" ]
#  do
#    "$@" && RC=0 && break || let count=count+1
#  done
#  return $RC
#}
start_time="$(date -u +%s)"
INVENTORY_FILE="/sas/install/common/ansible/playbooks/inventory.ini"
export ANSIBLE_STDOUT_CALLBACK=debug
export ANSIBLE_ANY_ERRORS_FATAL=True
export ANSIBLE_CONFIG=/sas/install/common/ansible/playbooks/ansible.cfg


pushd "${CODE_DIRECTORY}/ansible/playbooks"

# we need to map the inventory file from common, so lets symlink it
ln -s "$INVENTORY_FILE" "inventory.ini"

ANSIBLE_LOG_PATH=/var/log/sas/install/prepare_inventory.log \
                    export ANSIBLE_CONFIG=/sas/install/common/ansible/playbooks/ansible.cfg
                    ansible-playbook -vvv /sas/install/common/ansible/playbooks/assemble_main_inventory.yml \
                      -e "CAS_INSTANCE_COUNT=${CASInstanceCount}"

echo "Create LB certificate files"
time ansible-playbook -vvv create_load_balancer_cert.yml -i $INVENTORY_FILE -e "SSL_HOSTNAME=${PUBLIC_DNS_NAME}" -e "SSL_WORKING_FOLDER=${DIRECTORY_SSL_JSON_FILE}" -e "ARM_CERTIFICATE_FILE=${FILE_SSL_JSON_FILE}"

popd
finished_server_prerequisites="$(date -u +%s)"
touch "$TOUCHPOINT_PREREQUISITES"


echo "Preparing nodes"
ANSIBLE_LOG_PATH="${LOGS_DIR}/prepare_nodes.log" \
    time ansible-playbook -vvv "${CODE_DIRECTORY}/ansible/playbooks/prepare_nodes.yml" \
        -e SAS_INSTALL_DISK="256.00 GB" \
        --skip-tags mount_cascache \
        --skip-tags mount_userlib_dir \
        -e READINESS_FLAGS_DIR="${READINESS_FLAGS_DIR}" \
        -i $INVENTORY_FILE

echo "Building Controller and Services Cert"
pushd "${CODE_DIRECTORY}/ansible/playbooks"
    time ansible-playbook -vvv create_sas_cert.yml -i $INVENTORY_FILE -e SSL_WORKING_FOLDER="${DIRECTORY_SSL_JSON_FILE}" -e CODE_DIRECTORY="${CODE_DIRECTORY}"
    ret="$?"
    if [ "$ret" -ne "0" ]; then
        exit $ret
    fi
popd
finished_preparing_nodes="$(date -u +%s)"
touch "$TOUCHPOINT_PREORCHESTRATION"


if [ -n "${ADMINPASS}" ] && [ -n "${USERPASS}" ]; then

    ANSIBLE_LOG_PATH="${LOGS_DIR}/openldap.log" \
        time ansible-playbook -vvv /sas/install/ansible/playbooks/openldapsetup.yml \
            -e "OLCROOTPW='${ADMINPASS}'" \
            -e "OLCUSERPW='${USERPASS}'" \
            -i $INVENTORY_FILE \
            -i $INVENTORY_FILE

fi
openldap_installed_time="$(date -u +%s)"


if [[ "$DUMMY_LICENSE_STRING" != "$license_file_uri" ]]; then

    ANSIBLE_LOG_PATH=/var/log/sas/install/prepare_deployment.log \
        time ansible-playbook -vvv /sas/install/ansible/playbooks/prepare_deployment.yml \
          -e "DEPLOYMENT_MIRROR=${MIRROR_HTTP}" \
          -e "DEPLOYMENT_DATA_LOCATION=${license_file_uri}" \
          -e "ADMINPASS=${ADMINPASS}" \
          -e MIRROR_URL="file:///mnt/viyashare/mirror" \
          -e USE_MIRROR="True" \
          -e MIRROR_DIR="/mnt/viyashare/mirror" \
          -i $INVENTORY_FILE
    export ANSIBLE_INVENTORY=/sas/install/ansible/sas_viya_playbook/inventory.ini

    download_mirrors_and_orchestration_time="$(date -u +%s)"

    pushd /sas/install/ansible/sas_viya_playbook
    export ANSIBLE_CONFIG=/sas/install/ansible/sas_viya_playbook/ansible.cfg
    ANSIBLE_LOG_PATH=/var/log/sas/install/virk.log \
        time ansible-playbook -vvv /sas/install/ansible/sas_viya_playbook/viya-ark/playbooks/pre-install-playbook/viya_pre_install_playbook.yml \
            -e "use_pause=false" \
            --skip-tags skipmemfail,skipcoresfail,skipstoragefail,skipnicssfail,bandwidth \
            -e "DefaultTimeoutStartSec=3600s"
    ran_virk_time="$(date -u +%s)"


    ANSIBLE_LOG_PATH=/var/log/sas/install/viya_deployment.log \
        time ansible-playbook site.yml
    popd
    finished_time="$(date -u +%s)"


    export ANSIBLE_CONFIG=/sas/install/common/ansible/playbooks/ansible.cfg
    ANSIBLE_LOG_PATH=/var/log/sas/install/post_deployment.log \
        time ansible-playbook -vvv /sas/install/ansible/playbooks/post_deployment.yml -i $INVENTORY_FILE


    finished_post_orchestration_time="$(date -u +%s)"

    ANSIBLE_LOG_PATH=/var/log/sas/install/post_service_restart.log \
        time ansible-playbook -vvv /sas/install/common/ansible/playbooks/restart_services.yml -i $INVENTORY_FILE

    pushd "${CODE_DIRECTORY}/ansible/playbooks"
    echo "create cas sizing file"
    time ansible-playbook -vvv create_cas_uri_file.yml -i $INVENTORY_FILE -e CAS_URI_FILE="${CAS_URI_FILE}"
    popd
    finished_checking_for_restart="$(date -u +%s)"


    elapsed="$(($finished_server_prerequisites-$start_time))"
    printf 'Time to create setup files: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
    elapsed="$(($finished_preparing_nodes-$finished_server_prerequisites))"
    printf 'Time to prepare nodes: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
    elapsed="$(($openldap_installed_time-$finished_preparing_nodes))"
    printf 'Time to install openldap: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
    elapsed="$(($download_mirrors_and_orchestration_time-$openldap_installed_time))"
    printf 'Time to setup mirror and orchestration: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
    elapsed="$(($ran_virk_time-$download_mirrors_and_orchestration_time))"
    printf 'Time to run virk playbook: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
    elapsed="$(($finished_time-$ran_virk_time))"
    printf 'Time to run sas installer: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
    elapsed="$(($finished_post_orchestration_time-$finished_time))"
    printf 'Time to run post configuration: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
    elapsed="$(($finished_checking_for_restart-$finished_post_orchestration_time))"
    printf 'Time to check for services start and restart if necessary: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))
    elapsed="$(($finished_checking_for_restart-$start_time))"
    printf 'Total time: %02dh:%02dm:%02ds\n' $(($elapsed/3600)) $(($elapsed%3600/60)) $(($elapsed%60))

fi
