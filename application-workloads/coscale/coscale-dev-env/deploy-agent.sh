#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Execute the CoScale agent deploy command on all servers in a resource group."
    echo ""
    echo "Usage: $0 <resource-group> <command>"
    echo "   - resource-group: The resource group containing the vms on which you want to deploy CoScale."
    echo "   - command: The command to install the agent, as provided by the CoScale UI."
    echo ""
    exit 1
fi

export GROUP=$1
export COMMAND=$2

echo "Getting vm list"
SERVERS=`az vm list -g $GROUP -o table | tail -n +3 | awk '{ print $2; }'`

for SERVER in $SERVERS
do
    echo "Deploying on server $SERVER"
    az vm extension set \
        --publisher Microsoft.Azure.Extensions -n CustomScript --version 2.0 \
        --vm-name $SERVER --resource-group $GROUP \
        --protected-setting '{ "commandToExecute": "'"$COMMAND"'" }'
done
