---
description: This template creates an Azure Stack HCI 23H2 cluster using an ARM template.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-cluster
languages:
- json
---
# creates an Azure Stack HCI 23H2 cluster

This template allows you to create an Azure Stack HCI cluster using version 23H2. First you deploy the template in validate mode which does confirm the parameters at the device. Once passed you re-deploy the template with mode set to deploy.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster%2Fazuredeploy.json)

## Prerequisites

In order to deploy this template, you must have Arc enabled the server(s) and installed the mandatory extensions. In addition a set of permissions must be set and reousrces must be deployed prior running this template:

- A Service Principal must be created that has "Contributer" and "User Access Admin" permission at subscription level.
- A storage account that is used for the cluster witness configuration
- Validate that managed identity for each server has "Azure Stack HCI Device Management" role assigned at resource group level.
- Validate that managed identity for each server has "Reader" role assigned at resource group level.
- Validate that managed identity for each server has "Azure Connected Machine Resource Manager" role assigned at resource group level.
- Assign "Key Vault Secrets User" role to each managed identity for each server to the KeyVault created by the template at resource group level.
- Assign "Azure Connected Machine Resource Manager" role to "Microsoft.AzureStackHCI Resource Provider" at resource group level.


> [!NOTE]
> The secrets must be entered into the template being encoded using base64. Prior encoding the format must be "username:password" for credentials,for the SPN it must be "AppID:secret". The storage account key is directly encoded to base64. Here is a sample using PowerShell to encode to base64: 
$secret="username:password"
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($secret))

`Tags: Microsoft.AzureStackHCI/clusters, hci`