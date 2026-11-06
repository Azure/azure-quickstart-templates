---
description: Configure Azure Local nodes for external iSCSI SAN storage with optional CHAP authentication.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-local-node-configration
languages:
- json
---
# Configure Azure Local nodes for iSCSI SAN storage

This standalone ARM template creates an Azure Local edge machine and applies its iSCSI network configuration through `Microsoft.AzureStackHCI/edgeMachines/deploymentSettings`. It supports optional Key Vault-backed CHAP authentication.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fazure-local-node-configration%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](https://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fazure-local-node-configration%2Fazuredeploy.json)

## Resources

- HCI resource provider's Azure Connected Machine Resource Manager role assignment.
- Arc machine identities' Azure Stack HCI Device Management role assignments.
- CHAP credential validation and Key Vault Secrets User role assignments only when CHAP is enabled.
- An optional new RBAC-enabled Key Vault, Standard_LRS diagnostic storage account, and Key Vault audit settings only when CHAP is enabled.
- A shared CHAP secret when `chapType` is `OneWay` or `Mutual`.
- One edge machine and its `default` deployment settings per node, using API version `2026-10-01`.

## Prerequisites

- Register `Microsoft.HybridCompute`, `Microsoft.GuestConfiguration`, `Microsoft.HybridConnectivity`, `Microsoft.AzureStackHCI`, `Microsoft.KeyVault`, and `Microsoft.Storage`.
- Obtain the HCI resource provider service principal's object ID in your tenant.
- Use a deployment identity with permission to create the resources, write Key Vault secrets, and assign roles in the resource group.
- Configure the external iSCSI SAN and each node's initiator IQN and iSCSI network adapters. CHAP credentials must match the SAN configuration.
- Replace the example values in `azuredeploy.parameters.json`. Supply `chapCredential` securely at deployment time rather than committing a credential to the parameter file.

## Deployment

Deploy to the resource group containing the Arc machines.

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName '<resource-group-name>' `
  -TemplateFile '.\azuredeploy.json' `
  -TemplateParameterFile '.\azuredeploy.parameters.json' `
  -chapCredential (Read-Host 'CHAP secret' -AsSecureString)
```

Each `nodes` entry contains `arcNodeResourceId` and `iScsiNetworkConfig`. The network configuration contains `adapterProperties` and `adapterIPConfig`, as shown in the parameter file.

After each edge machine finishes provisioning, the template reads it using API version `2026-10-01`. It selects the first entry in `properties.reportedProperties.storageInitiators` whose `initiatorType` is `iSCSI` and uses its `initiatorIdentifier` as the deployment settings' `initiatorIqn`. No IQN input is required. The machine must report an iSCSI initiator before deployment settings can be applied; missing initiator data fails deployment.

## CHAP authentication

Set `chapType` to `None` to skip Key Vault, diagnostic storage, audit settings, secrets, and Key Vault RBAC. Vault and diagnostic storage names can be omitted. Node-management role assignments are still created.

For `OneWay` or `Mutual`, supply both `chapUsername` and `chapCredential`. Missing credentials fail validation. `Mutual` uses the same credential in both directions.

The secret name is fixed as `chapCredential`. Set `createNewKeyVault` to `false` to reuse an RBAC-enabled vault in the same resource group; no diagnostic storage or audit settings are created in that case. Writing the secret replaces its current value, so use separate vaults for independent credentials. New diagnostic storage accounts use `Standard_LRS`.

## Validation status

Successfully deployed to Azure with `chapType` set to `None`, including automatic IQN discovery and edge-machine deployment settings. Deployment evidence is recorded in `metadata.json`. CHAP-enabled deployment paths have not been tested live.

`Tags: Microsoft.AzureStackHCI/edgeMachines, Microsoft.AzureStackHCI/edgeMachines/deploymentSettings, hci, SAN, iSCSI`
