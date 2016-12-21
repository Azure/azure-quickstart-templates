#!/bin/bash

prefix="cf"
loc="East Asia"
tenantID="REPLACE-HERE"
clientID="REPLACE-HERE"
clientSecret="REPLACE-HERE"
username="REPLACE-HERE"
password="REPLACE-HERE"

get_id()
{
    UUID=$(cat /proc/sys/kernel/random/uuid)
    UUID=${UUID//-}
    echo ${UUID:0:22}
}

deploy()
{
    echo "scenario: $2"
    azure group create -n "$prefix$1" -l "$loc" -d "$2" -f ../azuredeploy.json -e $2.json
}

scenario="minimumconf"
id=`get_id`
cat > $scenario.json << EOF
{
  "\$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "newStorageAccountName": {
      "value": "$prefix$id"
    },
    "vmName": {
      "value": "$prefix$id"
    },
    "adminUsername": {
      "value": "$username"
    },
    "adminPassword": {
      "value": "$password"
    }
  }
}
EOF
deploy $id $scenario

scenario="maximumconf"
id=`get_id`
cat > $scenario.json << EOF
{
  "\$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "newStorageAccountName": {
      "value": "$prefix$id"
    },
    "virtualNetworkName": {
      "value": "boshvnet-crp"
    },
    "subnetNameForBosh": {
      "value": "Bosh"
    },
    "subnetNameForCloudFoundry": {
      "value": "CloudFoundry"
    },
    "vmName": {
      "value": "$prefix$id"
    },
    "vmSize": {
      "value": "Standard_A1"
    },
    "adminUsername": {
      "value": "$username"
    },
    "adminPassword": {
      "value": "$password"
    },
    "enableDNSOnDevbox": {
      "value": true
    },
    "tenantID": {
      "value": "$tenantID"
    },
    "clientID": {
      "value": "$clientID"
    },
    "clientSecret": {
      "value": "$clientSecret"
    }
  }
}
EOF
deploy $id $scenario

scenario="noserviceprincipal"
id=`get_id`
cat > $scenario.json << EOF
{
  "\$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "newStorageAccountName": {
      "value": "$prefix$id"
    },
    "vmName": {
      "value": "$prefix$id"
    },
    "vmSize": {
      "value": "Standard_A1"
    },
    "adminUsername": {
      "value": "$username"
    },
    "adminPassword": {
      "value": "$password"
    },
    "enableDNSOnDevbox": {
      "value": true
    }
  }
}
EOF
deploy $id $scenario

scenario="nodns"
id=`get_id`
cat > $scenario.json << EOF
{
  "\$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "newStorageAccountName": {
      "value": "$prefix$id"
    },
    "vmName": {
      "value": "$prefix$id"
    },
    "vmSize": {
      "value": "Standard_A1"
    },
    "adminUsername": {
      "value": "$username"
    },
    "adminPassword": {
      "value": "$password"
    },
    "enableDNSOnDevbox": {
      "value": false
    }
  }
}
EOF
deploy $id $scenario
