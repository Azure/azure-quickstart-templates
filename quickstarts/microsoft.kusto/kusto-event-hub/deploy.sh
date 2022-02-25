#!/bin/bash

##########################################################################
##  Deploys main.bicep

rg=$1

echo "Resource group:  $rg"

echo
echo "Deploying ARM template"

az deployment group create -n "deploy-$(uuidgen)" -g $rg \
    --template-file "main.bicep"