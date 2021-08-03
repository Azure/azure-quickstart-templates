# TODO Clean up readme

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/avd-backplane-with-network-and-storage-and-monitoring/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/avd-backplane-with-network-and-storage-and-monitoring/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/avd-backplane-with-network-and-storage-and-monitoring/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/avd-backplane-with-network-and-storage-and-monitoring/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/avd-backplane-with-network-and-storage-and-monitoring/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/avd-backplane-with-network-and-storage-and-monitoring/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.desktopvirtualization/avd-backplane-with-network-and-storage-and-monitoring/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.desktopvirtualization%2Favd-backplane-with-network-and-storage-and-monitoring%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.desktopvirtualization%2Favd-backplane-with-network-and-storage-and-monitoring%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.desktopvirtualization%2Favd-backplane-with-network-and-storage-and-monitoring%2Fazuredeploy.json)

---
page_type: resources
languages:
  - md
  - json
  - bicep
description: |
  Multi-module Bicep project that deploys a AVD environment in Azure including some prerequisites that AVD generally needs.
products:
  - azure
  - azure-virtual-desktop
---

#   Multi-module Bicep project for Azure Virtual Desktop (AVD)


## Contents


| File/folder                      | Description                                                                    |
|----------------------------------|--------------------------------------------------------------------------------|
| `main.bicep`                     | Main Bicep file that calls bicep modules to deploy AVD,vnet and log analytics  |
| `AVD-backplane-module.bicep`     | Bicep module that creates AVD Hostpool, AppGroup and Workspace                 |
| `AVD-network-module.bicep`       | Bicep module that creates a vnet and subnet                                    |
| `AVD-fileservices-module.bicep`  | Bicep module that creates a storage account and file share                     |
| `AVD-fileservices-privateendpoint-module.bicep`         | Bicep module to configure PE and Private DNS for Storage Account to AVD VNET            |
| `AVD-LogAnalytics.bicep`         | Bicep module that creates a log analytics workspace                            |
| `AVD-monitor-diag.bicep`         | Bicep module that configured diagnostic settings for AVD components            |
| `AVD-sig-module.bicep`         | Bicep module that creates Shared Image Gallery            |
| `AVD-image-builder-module.bicep`         | Bicep module that configures Azure Image builder and creates template. (Option to run a deployment script to start image build off)            |
| `main.json`                      | The JSON result after transpiling 1. Deploy-Modules.bicep                      |


## main.bicep
This main bicep file creates a Azure Virtual Desktop environment in Azure, based on Bicep 0.2 creating Resource Groups, AVD Backplane
components, Vnet with Subnet, Storage container with FileShare, Storage Private Endpoint, Log Analytics Workspace, Shared Image Gallery and Azure Image Builder Template. 
This main bicep file calls the bicep modules as outlined below.
 - AVD-backplane-module.bicep
 - AVD-network-module.bicep
 - AVD-fileservices-module.bicep
 - AVD-fileservices-privateendpoint-module.bicep
 - AVD-LogAnalytics.bicep
 - AVD-monitor-diag.bicep
 - AVD-sig-module.bicep
 - AVD-image-builder-module.bicep
 
## AVD-backplane-module.bicep
This Bicep Module creates AVD backplane components in Azure and connects all objects. The following objetcs
are created.
 - AVD Hostpool
 - AVD AppGroup
 - AVD Workspace
 This Bicep module can be run separatly or as part of main.bicep
 
 ## AVD-network-module.bicep
This Bicep Module creates networking components in Azure. The following objects are created.
 - Virtual Network
 - Subnet
 This Bicep module can be run separatly or as part of main.bicep

 ## AVD-fileservices-module.bicep
This Bicep Module creates File Services components in Azure. The following objects are created.
 - Storage Account
 - File Share
 This Bicep module can be run separatly or as part of main.bicep

## AVD-fileservices-privateendpoint-module.bicep
This Bicep Module creates a File Services Private Endpoint in Azure connected to the AVD VNET. The following objects are created.
 - Private Endpoint
 - Private DNS Zone Group
 - Private DNS Zone
 This Bicep module can be run separatly or as part of main.bicep
  ## AVD-LogAnalytics.bicep
This Bicep Module creates Log Analytics components in Azure. The following objects are created.
 - Log Analytics Workspace
 This Bicep module can be run separatly or as part of main.bicep

  ## AVD-monitor-diag.bicep
This Bicep Module configures Log Analytics diagnostics settings for AVD components in Azure. The following objects
are configured for Log Analytics
 - Workspace
 - Hostpool
 This Bicep module can be run separatly or as part of main.bicep

  ## AVD-sig-module.bicep
This Bicep Module creates a Shared Image Gallery and Image Definition. The following objects
are created
 - Shared Image Gallery
 - Shared Image Gallery Image Definition
 This Bicep module can be run separatly or as part of main.bicep

  ## AVD-image-builder-module.bicep
This Bicep Module creates components to run Azure Image Builder and update the Shared Image Gallery Image Definition. 
The following objects are created
 - User Assigned Managed Identity (UAMI)
 - Role for the UAMI to Modify Gallery and Template Images
 - Image Template - Optional Customisations to run Optimization Teams install Powershell scripts and Windows Updates (Uncomment if needed)
 
 Optional (Experimental)
 If parameter InvokeRunImageBuildThroughDeploymentScript in main.bicep is set to True then the following will be triggered:
 - Additional Role definitions created and assigned to UAMI to be able to run Image Template builds, become a managed identity operator and create the relevant container and storage accounts needed to run a script deployment using the Microsoft.Resources/deploymentScripts provider.
 - Using the Microsoft.Resources/deploymentScripts provider, spins up a container and storage account and runs a Powershell script to start the build of the AIB Image and upload the image once complete to the SIG definition created earlier.

 This process may leave some orphaned Resource Groups from Image Builder in your Subscription usually prefixed 'IT_SIGRESOUCEGROUPNAME'. Make sure to delete if not required and to avoid unecessary charges.
 
 
 This Bicep module can be run separatly or as part of main.bicep

## main.json
This file is the JSON output after transpiling 'main.bicep'
The following command was used: bicep build '.\main.bicep'

## Contributing

This project welcomes contributions and suggestions.

TODO: Clean up README

