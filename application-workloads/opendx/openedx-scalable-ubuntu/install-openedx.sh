#!/bin/bash
# Copyright (c) Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT license. See LICENSE file on the project webpage for details.

set -x

APP_VM_COUNT=$1
ADMIN_USER=$2
ADMIN_PASS=$3
ADMIN_HOME=/home/$ADMIN_USER

EDX_VERSION="named-release/dogwood.rc"

# Run edX bootstrap
ANSIBLE_ROOT=/edx/app/edx_ansible
CONFIGURATION_REPO=https://github.com/Microsoft/edx-configuration.git
CONFIGURATION_VERSION="lex/scalable-dogwood"
wget https://raw.githubusercontent.com/edx/configuration/master/util/install/ansible-bootstrap.sh -O- | bash

# Stage configuration files
PLATFORM_REPO=https://github.com/edx/edx-platform.git
PLATFORM_VERSION=$EDX_VERSION

for i in `seq 1 $(($APP_VM_COUNT-1))`; do
  echo "openedx-app$i" >> inventory.ini
done

bash -c "cat <<EOF >extra-vars.yml
---
edx_platform_repo: \"$PLATFORM_REPO\"
edx_platform_version: \"$PLATFORM_VERSION\"
edx_ansible_source_repo: \"$CONFIGURATION_REPO\"
configuration_version: \"$CONFIGURATION_VERSION\"
certs_version: \"$EDX_VERSION\"
forum_version: \"$EDX_VERSION\"
xqueue_version: \"$EDX_VERSION\"
COMMON_SSH_PASSWORD_AUTH: \"yes\"
EOF"
cp *.{ini,yml} $ANSIBLE_ROOT
chown edx-ansible:edx-ansible $ANSIBLE_ROOT/*.{ini,yml}


# Setup SSH for remote installation
apt-get -y install sshpass
function send-ssh-key {
    host=$1;user=$2;pass=$3;
    cat /home/$user/.ssh/id_rsa.pub | sshpass -p $pass ssh -o "StrictHostKeyChecking no" $user@$host 'cat >> .ssh/authorized_keys';
}

if [ ! -f $ADMIN_HOME/.ssh/id_rsa ]
then
    ssh-keygen -f $ADMIN_HOME/.ssh/id_rsa -t rsa -N ''
    chown -R $ADMIN_USER:$ADMIN_USER $ADMIN_HOME/.ssh/
fi

for i in `seq 0 $(($APP_VM_COUNT-1))`; do
  send-ssh-key openedx-app$i $ADMIN_USER $ADMIN_PASS
done
send-ssh-key openedx-mysql $ADMIN_USER $ADMIN_PASS
send-ssh-key openedx-mongo $ADMIN_USER $ADMIN_PASS

# Install edX platform
cd /tmp
git clone $CONFIGURATION_REPO configuration

cd configuration
git checkout $CONFIGURATION_VERSION
pip install -r requirements.txt

cd playbooks
export ANSIBLE_OPT_VARS="-e@$ANSIBLE_ROOT/server-vars.yml -e@$ANSIBLE_ROOT/extra-vars.yml"
export ANSIBLE_OPT_SSH="-u $ADMIN_USER --private-key=$ADMIN_HOME/.ssh/id_rsa"

sudo ansible-playbook edx_mongo.yml -i "openedx-mongo," $ANSIBLE_OPT_SSH $ANSIBLE_OPT_VARS
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

sudo ansible-playbook edx_mysql.yml -i "openedx-mysql," $ANSIBLE_OPT_SSH $ANSIBLE_OPT_VARS
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

sudo ansible-playbook edx_sandbox.yml -i "localhost," -c local $ANSIBLE_OPT_VARS -e "migrate_db=yes"
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

sudo ansible-playbook edx_sandbox.yml -i $ANSIBLE_ROOT/inventory.ini $ANSIBLE_OPT_SSH $ANSIBLE_OPT_VARS --limit app
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
