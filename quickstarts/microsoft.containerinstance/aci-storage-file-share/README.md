# Create a Storage Account and a File Share

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aci-storage-file-share/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aci-storage-file-share/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aci-storage-file-share/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aci-storage-file-share/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aci-storage-file-share/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.containerinstance/aci-storage-file-share/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerinstance%2Faci-storage-file-share%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerinstance%2Faci-storage-file-share%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.containerinstance%2Faci-storage-file-share%2Fazuredeploy.json)

Create a Storage Account and a File Share via az-cli in Container Instance

This template demonstrates creating a Storage File Share via az-cli and Azure Container Instance. Modify the template to create a blob or other similar storage operation. The Azure Container Instance and az-cli can be used to create services not directly available in an Azure Resource Manager Template.

`Tags: Azure Container Instance, az-cli`

## Solution overview and deployed resources

The following resources are deployed as part of the solution

+ **Storage Account**: Storage account for the file share
+ **Azure Container Instance**: Azure Container Instance, where the az-cli is executed to create the file share
+ **File share**: [Azure File share](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction) accessiable via SMB protocol

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

#### Mount

Mount via SMB protocol on [Windows](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows), [Linux](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux), [macOS](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-mac) or [Azure Container Instance](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-volume-azure-files)

## Notes
Azure Container Instance is available in selected [locations](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quotas#region-availability). Please use one of the available location for Azure Container Instance resource.


