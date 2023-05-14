#!/bin/bash

##########################################################################
##  1- Name of resource group

rg=$1

echo "Resource group:  $rg"

echo
echo "Deploying ARM template"

az deployment group create -n "deploy-$(uuidgen)" -g vp-cosmos-arm3 \
    --template-file main.bicep
