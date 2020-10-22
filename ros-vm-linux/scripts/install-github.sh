#!/bin/bash

set -e

# install required tools
sudo apt update
sudo apt install -y curl jq

MY_RUNNER_AGENTNAME=$1
MY_RUNNER_REPO=$2
MY_RUNNER_TOKEN=$3
MY_RUNNER_LOCALADMIN=$4

echo "runner name: ${MY_RUNNER_AGENTNAME}"
echo "runner scope: ${MY_RUNNER_REPO}"
echo "runner user: ${MY_RUNNER_LOCALADMIN}"

pushd /home/${MY_RUNNER_LOCALADMIN}

# run the automation script
# https://github.com/actions/runner/blob/master/docs/automate.md
curl -s https://raw.githubusercontent.com/actions/runner/automate/scripts/create-latest-svc.sh | sudo RUNNER_CFG_PAT="${MY_RUNNER_TOKEN}" RUNNER_ALLOW_RUNASROOT="1" bash -s -- "${MY_RUNNER_REPO}" "${MY_RUNNER_AGENTNAME}" "${MY_RUNNER_LOCALADMIN}"
