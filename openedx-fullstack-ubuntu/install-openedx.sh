#!/bin/bash
# Copyright (c) Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT license. See LICENSE file on the project webpage for details.

set -xe

# Provide default if no parameter is passed.
export OPENEDX_RELEASE=${1:-"open-release/ficus.master"}
export CONFIGURATION_VERSION=$OPENEDX_RELEASE
CONFIG_REPO=https://github.com/edx/configuration.git
ANSIBLE_ROOT=/edx/app/edx_ansible
CONFIGURATION_ROOT=/tmp/configuration
CURRENT_SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

update_packages()
{
    for (( b=1; b<=3; b++ ))
    do
        echo
        echo "$1 packages..."
        echo
        sudo apt-get $1 -y -qq --fix-missing
        if [ $? -eq 0 ]; then
            break
        else
            echo "$1 failed"
        fi
    done
}
verify_ssh()
{
    if [ ! -f "/etc/ssh/sshd_config" ]; then
        echo "installing ssh..."
        apt-get install -y -qq ssh
    fi
}

install_ansible()
{
    # This URL structure works when $OPENEDX_RELEASE is a branch or tag in the configuration repo.
    wget https://raw.githubusercontent.com/edx/configuration/$OPENEDX_RELEASE/util/install/ansible-bootstrap.sh -O ansible-bootstrap.sh
    source ansible-bootstrap.sh
}

write_settings_to_file()
{
    pushd $CURRENT_SCRIPT_PATH

    bash -c "cat <<EOF >extra-vars.yml
---
edx_platform_version: \"$OPENEDX_RELEASE\"
certs_version: \"$OPENEDX_RELEASE\"
forum_version: \"$OPENEDX_RELEASE\"
xqueue_version: \"$OPENEDX_RELEASE\"
configuration_version: \"$CONFIGURATION_VERSION\"
PROGRAMS_VERSION: \"$OPENEDX_RELEASE\"
demo_version: \"$OPENEDX_RELEASE\"
edx_ansible_source_repo: \"$CONFIG_REPO\"
COMMON_SSH_PASSWORD_AUTH: \"yes\"
EDXAPP_SITE_NAME: \"$HOSTNAME\"
EOF"

    cp *.yml $ANSIBLE_ROOT
    chown edx-ansible:edx-ansible $ANSIBLE_ROOT/*.yml
}

# Execution start

# Disable "immediate exit" on errors to allow for retry
set +e
update_packages update
update_packages upgrade
# Enable "immediate exit" on error
set -e

verify_ssh
install_ansible
write_settings_to_file

if [ ! -d $CONFIGURATION_ROOT ]; then
    git clone $CONFIG_REPO $CONFIGURATION_ROOT
fi

cd $CONFIGURATION_ROOT
git checkout $CONFIGURATION_VERSION
pip install -r requirements.txt

cd playbooks

# Disable "immediate exit" on errors to allow for retry
set +e

#retry transient failures
MAX_ATTEMPTS=10
retry_count=1
until [ $retry_count -gt $MAX_ATTEMPTS ]
do
    echo
    echo "starting attempt number: $retry_count"
    echo
    ansible-playbook -i localhost, -c local vagrant-fullstack.yml -e@$ANSIBLE_ROOT/server-vars.yml -e@$ANSIBLE_ROOT/extra-vars.yml

    if [ $? -eq 0 ]; then
        echo "attempt number: $retry_count succeeded!"
        break
    else
        echo "attempt number: $retry_count failed"
        update_packages update
        update_packages upgrade
    fi
    $retry_count=$retry_count+1
done

# Enable "immediate exit" on error
set -e

