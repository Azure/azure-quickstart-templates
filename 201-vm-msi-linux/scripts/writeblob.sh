#!/bin/bash

if [ -z $CONTAINER_NAME ]; then
    CONTAINER_NAME="msi"
else
    CONTAINER_NAME=$(echo "$CONTAINER_NAME"|tr '[:upper:]' '[:lower:]')
fi

# The default port for the MSI extension is 50342

if [ -z $PORT ]; then
    PORT=50342
fi

for var in STORAGE_ACCOUNT RESOURCE_GROUP 
do

    if [ -z ${!var} ]; then
        echo "Argument $var is not set" >&2
        exit 1
    fi

done

# login using msi 

az login --msi --msi-port ${PORT}

# create a file and upload it to storage account using a key obtained via the logged in MSI , the MSI must have permission to perfrm these operations

storage_account_key=`az storage account keys list -n ${STORAGE_ACCOUNT} -g ${RESOURCE_GROUP}|jq '.[0].value'`

if [ `az storage container exists -n ${CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT} --account-key ${storage_account_key} |jq '.exists'` = 'false' ]; then
    echo "Creating container ${CONTAINER_NAME} in storage account ${STORAGE_ACCOUNT}"
    az storage container create -n ${CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT} --account-key ${storage_account_key}
fi

blob_name=$(hostname|tr '[:upper:]' '[:lower:]')
file_name=mktemp
date > $file_name
az storage blob upload --container-name ${CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT} --account-key ${storage_account_key} --name ${blob_name} --file ${file_name}