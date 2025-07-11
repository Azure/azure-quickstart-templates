---
description: This template creates an Azure Stack HCI 23H2 cluster using an ARM template, using custom storage IP
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-cluster-2-node-switched-custom-storageip
languages:
- json
---
# creates an Azure Stack HCI 23H2 cluster

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/create-cluster/BicepVersion.svg)

This template allows you to create an Azure Stack HCI cluster using version 23H2. First you deploy the template in validate mode which does confirm the parameters at the device. Once passed you re-deploy the template with mode set to deploy.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster%2Fazuredeploy.json)

## Prerequisites

In order to deploy this template, you must have Arc enabled the server(s) and installed the mandatory extensions. The following pre-requisites must be completed:
- Register these resource providers
    - Microsoft.HybridCompute
    - Microsoft.GuestConfiguration
    - Microsoft.HybridConnectivity
    - Microsoft.AzureStackHCI
- Make a note of the HCI Resource Provider SPNs Object ID in the tenant.

`Tags: Microsoft.AzureStackHCI/clusters, hci`
