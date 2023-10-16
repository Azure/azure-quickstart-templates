---
description: This template creates an Azure Stack HCI Image from an Azure Marketplace Gallery Image.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: image-from-azure-marketplace
languages:
- bicep
- json
---
# creates an Azure Stack HCI Image from Marketplace Image

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/image-from-azure-marketplace/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/image-from-azure-marketplace/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/image-from-azure-marketplace/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/image-from-azure-marketplace/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/image-from-azure-marketplace/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/image-from-azure-marketplace/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/image-from-azure-marketplace/BicepVersion.svg)

This template allows you to deploy a new Azure Stack HCI Image from the referenced Azure Marketplace image. See [Azure Stack HCI Images](/azure-stack/hci/manage/virtual-machine-image-azure-marketplace)

Only the Azure Marketplace images listed below are supported on Azure Stack HCI as of September, 1st 2023.

|Image Description| Image URN|
|--|--|
|Windows Server 2022 Datacenter: Azure Editition Core - Gen2|                                           microsoftwindowsserver:windowsserver:2022-datacenter-azure-edition-core|
|Windows Server 2022 Datacenter: Azure Editition - Gen2|                                                microsoftwindowsserver:windowsserver:2022-datacenter-azure-edition|
|Windows 11 Enterprise multi-session + Microsoft 365 Apps, version 21H2 - Gen2|                         microsoftwindowsdesktop:office-365:win11-21h2-avd-m365|
|Windows 10 Enterprise multi-session, version 21H2 + Microsoft 365 Apps - Gen2|                         microsoftwindowsdesktop:office-365:win10-21h2-avd-m365-g2|
|Windows 10 Enterprise multi-session, version 21H2 - Gen2|                                              microsoftwindowsdesktop:windows-10:win10-21h2-avd-g2|
|Windows 11 Enterprise multi-session, version 21h2 - Gen2|                                              microsoftwindowsdesktop:windows-11:win11-21h2-avd|
|Windows 11 Enterprise multi-session, version 22h2 - Gen2|                                              microsoftwindowsdesktop:windows-11:win11-22h2-avd|

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fimage-from-azure-marketplace%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fimage-from-azure-marketplace%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fimage-from-azure-marketplace%2Fazuredeploy.json)

## Prerequisites

In order to deploy this template, there must be an operational ARC Resource Bridge associated with your Azure Stack HCI cluster. Further, the Custom Location resource must be deployed before running this template. The Custom Location is a resource representing your Azure Stack HCI Cluster in Azure.

> [!NOTE]
> For simplicity, this template assumes the Custom Location resides in the same Resource Group as where the Image is being created.

`Tags: Microsoft.AzureStackHCI/marketplacegalleryimages`