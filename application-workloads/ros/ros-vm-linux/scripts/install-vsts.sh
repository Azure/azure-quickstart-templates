#!/bin/bash

set -e

# install required tools
sudo apt update
sudo apt install -y curl jq

VSTS_AGENTNAME=$1
VSTS_ACCOUNT=$2
VSTS_TOKEN=$3
VSTS_POOL=$4

DESTINATION="$HOME/vsts-agent"

mkdir -p $DESTINATION

# download the latest agent
VSTSVERSION=$(curl -s "https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest" | jq -r .tag_name[1:])
echo $VSTSVERSION
curl -LO https://vstsagentpackage.azureedge.net/agent/${VSTSVERSION}/vsts-agent-linux-x64-${VSTSVERSION}.tar.gz
tar -zxvf vsts-agent-linux-x64-${VSTSVERSION}.tar.gz -C $DESTINATION

chmod -R 777 $DESTINATION

# configure
sudo AGENT_ALLOW_RUNASROOT="1" $DESTINATION/config.sh --unattended \
  --agent "$VSTS_AGENTNAME" \
  --url "https://dev.azure.com/$VSTS_ACCOUNT" \
  --auth PAT \
  --token "$VSTS_TOKEN" \
  --pool "$VSTS_POOL" \
  --replace \
  --acceptTeeEula

echo "configuration done"

pushd $DESTINATION

sudo ./svc.sh install

echo "service installed"

sudo ./svc.sh start

echo "service started"
