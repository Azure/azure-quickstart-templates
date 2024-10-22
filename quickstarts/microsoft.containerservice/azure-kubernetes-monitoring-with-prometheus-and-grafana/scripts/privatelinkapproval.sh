#!/bin/bash
set -e

# Approve private endpoint connection
pecname=$(az network private-endpoint-connection list \
  --name $PRIVATE_LINK_SERVICE_NAME \
  --resource-group $PRIVATE_LINK_SERVICE_RG \
  --type  $PRIVATE_LINK_SERVICE_TYPE \
  --query "[0].name" --output tsv)

az network private-endpoint-connection approve \
  --name $pecname \
  --resource-name $PRIVATE_LINK_SERVICE_NAME \
  --resource-group $PRIVATE_LINK_SERVICE_RG \
  --description "Please approve $PLS_RESOURSENAME" \
  --type  $PRIVATE_LINK_SERVICE_TYPE