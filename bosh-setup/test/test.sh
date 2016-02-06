#!/bin/bash

prefix="cf"
loc="CHANGE-ME"

username="CHANGE-ME"
sshKeyData="CHANGE-ME"

tenantID="CHANGE-ME"
clientID="CHANGE-ME"
clientSecret="CHANGE-ME"

get_id()
{
    UUID=$(cat /proc/sys/kernel/random/uuid)
    UUID=${UUID//-}
    echo ${UUID:0:22}
}

deploy()
{
    echo "scenario: $2"
    azure group create -n "$prefix$1" -l "$loc" -d "$2"  -f ../azuredeploy.json -e $2.json -vv
}

scenario="minimum"
id=`get_id`
cat > $scenario.json << EOF
{
  "\$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmName": {
      "value": "$prefix$id"
    },
    "adminUsername": {
      "value": "$username"
    },
    "sshKeyData": {
      "value": "$sshKeyData"
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

scenario="auto-deploy-bosh"
id=`get_id`
cat > $scenario.json << EOF
{
  "\$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmName": {
      "value": "$prefix$id"
    },
    "adminUsername": {
      "value": "$username"
    },
    "sshKeyData": {
      "value": "$sshKeyData"
    },
    "tenantID": {
      "value": "$tenantID"
    },
    "clientID": {
      "value": "$clientID"
    },
    "clientSecret": {
      "value": "$clientSecret"
    },
    "autoDeployBosh": {
      "value": "enabled"
    }
  }
}
EOF
deploy $id $scenario

scenario="with-additional-storage-accounts"
id=`get_id`
cat > $scenario.json << EOF
{
  "\$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmName": {
      "value": "$prefix$id"
    },
    "adminUsername": {
      "value": "$username"
    },
    "sshKeyData": {
      "value": "$sshKeyData"
    },
    "tenantID": {
      "value": "$tenantID"
    },
    "clientID": {
      "value": "$clientID"
    },
    "clientSecret": {
      "value": "$clientSecret"
    },
    "additionalStorageAccounts": {
      "value": "enabled"
    },
    "additionalStorageAccountsNumber": {
      "value": 3
    }
  }
}
EOF
deploy $id $scenario

scenario="with-azure-dns"
id=`get_id`
cat > $scenario.json << EOF
{
  "\$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmName": {
      "value": "$prefix$id"
    },
    "adminUsername": {
      "value": "$username"
    },
    "sshKeyData": {
      "value": "$sshKeyData"
    },
    "tenantID": {
      "value": "$tenantID"
    },
    "clientID": {
      "value": "$clientID"
    },
    "clientSecret": {
      "value": "$clientSecret"
    },
    "azureDNS": {
      "value": "enabled"
    },
    "systemDomainName": {
      "value": "mslovelinux.com"
    }
  }
}
EOF
deploy $id $scenario

scenario="all"
id=`get_id`
cat > $scenario.json << EOF
{
  "\$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmName": {
      "value": "$prefix$id"
    },
    "adminUsername": {
      "value": "$username"
    },
    "sshKeyData": {
      "value": "$sshKeyData"
    },
    "tenantID": {
      "value": "$tenantID"
    },
    "clientID": {
      "value": "$clientID"
    },
    "clientSecret": {
      "value": "$clientSecret"
    },
    "autoDeployBosh": {
      "value": "enabled"
    },
    "additionalStorageAccounts": {
      "value": "enabled"
    },
    "additionalStorageAccountsNumber": {
      "value": 3
    },
    "azureDNS": {
      "value": "enabled"
    },
    "systemDomainName": {
      "value": "mslovelinux.com"
    }
  }
}
EOF
deploy $id $scenario

echo "FINISH"
