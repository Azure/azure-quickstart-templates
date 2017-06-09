#!/bin/bash
# Copyright (c) Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT license. See LICENSE file on the project webpage for details.

set -x
CONFIG_REPO=https://github.com/edx/configuration.git

wget https://raw.githubusercontent.com/satyarapelly/azure-quickstart-templates/master/badgr-fullstack-ubuntu/badgr-bootstrap.sh -O- | bash

cd /tmp
git clone $CONFIG_REPO

