---
description: This template creates an Azure Stack HCI 23H2 cluster using a Bicep template.
page_type: sample
products:
- azure
- Bicep
urlFragment: create-cluster-Bicep
languages:
- json
---
# Creates an Azure Stack HCI 23H2 cluster and supporting resources

This template allows you to create an Azure Stack HCI cluster using version 23H2+, and all of the supporting resources e.g.

- Key Vault - which will be named *deploymentprefix*-hcikv
- Key Vault Diagnostic Storage Account - which will be named *deploymentprefix*diag
- Cloud Witness Storage Account - which will be named *deploymentprefix*witness
- Customer Location - which will be named *deploymentprefix*_cl 

The deployment with 3 intents, one each for management, compute and storage, with storage in switch configuration 

First you deploy the template in validate mode which does confirm the parameters at the device. Once passed you re-deploy the template with mode set to deploy.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster%2Fazuredeploy.json)

## Prerequisites

In order to deploy this template, you must have Arc enabled the server(s) and installed the mandatory extensions. In addition a set of permissions must be set and resources must be deployed prior running this template:

- A Service Principal must be created that has "Contributor" and "User Access Admin" permission at subscription level.
- The account running the deployment must be "Contributor" and "User Access Admin" permission at resource group Level

All additional required permissions are assigned during the deployment and these are:

- Key Vault Secret User to each of the Managed Identities of the nodes, at the Key Vault resource level
- Connected MachineResource Manager to each of the Managed Identities of the nodes, and the Microsoft.AzureStackHCI Resource Provider, at the resource group level
- Azure Stack HCI Device Management Role  to each of the Managed Identities of the nodes, at the resource group level
- Reader to each of the Managed Identities of the nodes, at the resource group level

> [!NOTE]
> The Key Vault secrets are encoded using base64 as part of the deployment
> 
> Within [azuredeploy.parameters.json](.\azuredeploy.parameters.json) the storageNetworks parameter needs to include an array of at least two storage network object with both an adapterName and vlan property: e.g
> 
>       "storageAdapters": {"value":[
>      {"adapterName":"smb1","vlan":"711"},
>      {"adapterName":"smb2","vlan":"712"}
>      ]
>

`Tags: Microsoft.AzureStackHCI/clusters, hci`