#!/bin/bash
# Copyright (c) Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT license. See LICENSE file on the project webpage for details.

set -x
export OPENEDX_RELEASE=${1:-"open-release/ficus.master"}
CONFIG_REPO=https://github.com/edx/configuration.git
ANSIBLE_ROOT=/edx/app/edx_ansible

wget https://raw.githubusercontent.com/edx/configuration/open-release/ficus.master/util/install/ansible-bootstrap.sh -O- | bash

bash -c "cat <<EOF >extra-vars.yml
---
edx_platform_version: \"$OPENEDX_RELEASE\"
certs_version: \"$OPENEDX_RELEASE\"
forum_version: \"$OPENEDX_RELEASE\"
xqueue_version: \"$OPENEDX_RELEASE\"
configuration_version: \"$OPENEDX_RELEASE\"
edx_ansible_source_repo: \"$CONFIG_REPO\"
COMMON_SSH_PASSWORD_AUTH: \"yes\"
EOF"
cp *.yml $ANSIBLE_ROOT
chown edx-ansible:edx-ansible $ANSIBLE_ROOT/*.yml

cd /tmp
git clone $CONFIG_REPO

cd configuration
git checkout $OPENEDX_RELEASE
pip install -r requirements.txt


cd playbooks

# Disable "immediate exit" on errors to allow for retry
set +e

# ansible-playbook -i localhost, -c local vagrant-fullstack.yml -e@$ANSIBLE_ROOT/server-vars.yml -e@$ANSIBLE_ROOT/extra-vars.yml

#if [ ! -d "/edx/app/edxapp" ]; then
#  echo "retry edxapp configuration..."
#  wget https://raw.githubusercontent.com/edx/configuration/$OPENEDX_RELEASE/util/install/sandbox.sh -O - | bash
#fi

for (( a=1; a<=11; a++ )) 
  do      
    echo      
    echo "starting attempt number: $a"      
    echo      
    ansible-playbook -i localhost, -c local vagrant-fullstack.yml -e@$ANSIBLE_ROOT/server-vars.yml -e@$ANSIBLE_ROOT/extra-vars.yml
    if [ $? -eq 0 ]; then          
      echo "attempt number: $a succeeded!"          
      break      
    else          
      echo "attempt number: $a failed"          
      update_packages update          
      update_packages upgrade      
    fi
  done   

# Enable "immediate exit" on error
set -e
