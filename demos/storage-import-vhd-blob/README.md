# Import VHD from Blob URI

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-import-vhd-blob/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-import-vhd-blob/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-import-vhd-blob/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-import-vhd-blob/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-import-vhd-blob/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/storage-import-vhd-blob/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fstorage-import-vhd-blob%2Fazuredeploy.json) [![Deploy to Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fstorage-import-vhd-blob%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fstorage-import-vhd-blob%2Fazuredeploy.json)

To deploy Virtual Machines based on specialized disk images you need to import VHD files into a Storage Account, and those VHD can come from various sources.

In case the source is a Blob and you got the URI ready for the transfer, this ARM template allows to import with ease into an existing Blob Container of a Storage Account.

## Prerequisites

- URI of the Blob containing the VHD to transfer. For example a URI with a SAS Token having read permissions.

- URI with a SAS Token having write permissions to an existing Blob Container of Storage Account.

## Deployment steps

1. Hit the "Deploy to Azure" button above
2. Set usual fields:
    - Subscription
    - Resource Group: create a new. For example: Temporary-ImportVHD
    - Region: any Azure Region. For example: francecentral
3. Fill the parameters
    - *Location: Can be skipped. It sets the Azure region for the temporary resources. Keeping [resourceGroup().location] will use the region set above for the resource group. Other Azure Region can be set, for example francecentral
    - Source: URI of a Blob (VHD to copy)
    - Destination: URI with SAS Token having write permisson to the destination Blob Container
4. Hit "Review + create", then hit "Create" and wait for the deployment

## Usage

It might take few minutes depending on the size of the VHD and the location.

When the deployment is done, you can start using the VHD that has been imported as a Blob in the Storage Account Container.

For example create Disk or Image resources and then some Virtual Machines.

### Demo

This template is used by the [Riverbed Community Cookbooks simple demo for AppResponse](https://github.com/riverbed/Riverbed-Community-Toolkit/tree/master/AppResponse/Azure-Cloud-Cookbooks/101-appresponse-simple-demo)

## Notes

`Tags: storage, import, vhd, specialized image`
