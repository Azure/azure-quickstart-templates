#!/bin/bash
# Copyright (c) Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT license. See LICENSE file on the project webpage for details.
set -x

setup() {
  if [[ ! -d /lex ]]; then
    mkdir /lex
    cp $0 /lex
    cp server-vars.yml /lex

    wget https://raw.githubusercontent.com/edx/configuration/master/util/install/ansible-bootstrap.sh -O- | bash

    EDX_VERSION="named-release/dogwood.rc"
    CONFIGURATION_REPO=https://github.com/Microsoft/edx-configuration.git
    CONFIGURATION_VERSION="lex/scalable-dogwood"

    bash -c "cat <<EOF >/lex/extra-vars.yml
---
edx_platform_version: \"$EDX_VERSION\"
edx_ansible_source_repo: \"$CONFIGURATION_REPO\"
configuration_version: \"$CONFIGURATION_VERSION\"
certs_version: \"$EDX_VERSION\"
forum_version: \"$EDX_VERSION\"
xqueue_version: \"$EDX_VERSION\"
COMMON_SSH_PASSWORD_AUTH: \"yes\"
EOF"

    cd /lex
    git clone $CONFIGURATION_REPO configuration

    cd configuration
    git checkout $CONFIGURATION_VERSION

    pip install -r requirements.txt
  fi
  
  cd /lex/configuration/playbooks
}

EDX_ROLE=$1
ANSIBLE_ARGS='-i localhost, -c local -e@/lex/server-vars.yml -e@/lex/extra-vars.yml'
case "$EDX_ROLE" in
  mongo)
    setup
    sudo ansible-playbook edx_mongo.yml $ANSIBLE_ARGS
    ;;
  mysql)
    setup
    sudo ansible-playbook edx_mysql.yml $ANSIBLE_ARGS
    # minimize tags? "install:base,install:system-requirements,install:configuration,install:app-requirements,install:code"
    sudo ansible-playbook edx_sandbox.yml $ANSIBLE_ARGS -e "migrate_db=yes" --tags "edxapp-sandbox,install,migrate"
    ;;
  edxapp)
    setup
    sudo ansible-playbook edx_sandbox.yml $ANSIBLE_ARGS -e "migrate_db=no"
    ;;
  *)
    echo "Usage: $0 [mongo|mysql|edxapp]"
    exit 1
    ;;
esac
