#!/bin/bash
set -e

while getopts "r:s" opt; do
    case $opt in
        r)
            roles=$OPTARG # coma seperated roles
        ;;
        s)
            subscription=$OPTARG #optional subscription ID
        ;;
    esac
done

[[ $# -eq 0 || -z $roles ]] && { echo "Usage: $0 -r <comma seperated role(s)>"; exit 1; }

# install jq if not installed
if ! command -v jq &> /dev/null
then
    echo "jq command not found. attempting to download jq binary"
    pth=$(pwd)
    export PATH=$PATH:$pth
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -LO https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 jq
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        curl -LO https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64 jq
    else
        echo "Unsupported OS type. Exiting..."
        exit 1
    fi
    chmod +x jq
fi

IFS=','; rolesArr=($roles); unset IFS;
role1="${rolesArr[0]}"
subscriptionId=$( az account show -o json | jq -r '.id' )

# Create service principal with first
spJson=$(az ad sp create-for-rbac --role="$role1" --scopes="/subscriptions/$subscriptionId")
aadClientId=$(echo $spJson | jq -r '.appId')
aadClientSecret=$(echo $spJson | jq -r '.password')

# Get object object id
objectId=$( az ad sp list --filter "appId eq '$aadClientId'" | jq '.[0].objectId' -r )

# assign roles 
for role in "${rolesArr[@]}"
do
    echo "Creating role $role"
    az role assignment create --role "$role" --assignee-object-id $objectId
done

echo " Creation Complete "

echo " - ClientID => $aadClientId"
echo " - ClientSecret => $aadClientSecret"
