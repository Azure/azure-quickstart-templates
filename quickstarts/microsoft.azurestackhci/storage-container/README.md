---
description: This template creates an Azure Stack HCI Storage Path/Container representing a physical path on the Azure Stack HCI cluster.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: storage-container
languages:
- bicep
- json
---
# Create an Azure Stack HCI Storage Path

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/storage-container/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/storage-container/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/storage-container/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/storage-container/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/storage-container/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/storage-container/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/storage-container/BicepVersion.svg)

This template creates a Storage Path/Container in Azure, representing a physical path in your on-prem Azure Stack HCI cluster. This resource is used in the creation of VMs and images to target a specific path rather than any CSV with space.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fstorage-container%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fstorage-container%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fstorage-container%2Fazuredeploy.json)

## Prerequisites

In order to deploy this template, there must be an operational ARC Resource Bridge associated with your Azure Stack HCI cluster. Further, the resources below must be deployed before running this template:

- Custom Location: This is the custom location resource representing your Azure Stack HCI Cluster in Azure. The following Virtual Network and Image resources must be associated with this custom location.

> [!NOTE]
> For simplicity, this template assumes the Custom Location, Virtual Network, and Image all reside in the same Resource Group as where the Virtual Machine is being created. 

`Tags: Microsoft.AzureStackHCI/storageContainers, hci`