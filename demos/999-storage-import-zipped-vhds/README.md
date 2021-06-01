# Import VHD files from ZIP Archive URL

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/999-storage-import-zipped-vhds/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/999-storage-import-zipped-vhds/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/999-storage-import-zipped-vhds/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/999-storage-import-zipped-vhds/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/999-storage-import-zipped-vhds/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/999-storage-import-zipped-vhds/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F999-storage-import-zipped-vhds%2Fazuredeploy.json) [![Deploy to Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F999-storage-import-zipped-vhds%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2F999-storage-import-zipped-vhds%2Fazuredeploy.json)

To deploy Virtual Machines based on specialized disk images you need to import VHD files into a Storage Account, and those VHD can come from various sources.

In the case there are multiple VHD files compressed in a single ZIP and you got the URL to fetch the ZIP archive, this ARM template will ease the job: Download, Extract and Import into an existing Storage Account Blob Container.

Simply hit "Deploy to Azure" button.

## Prerequisites

- URL of a ZIP Archive containing VHD files

- URI of a Storage Account Blob Container with a SAS Token granting write permissions

## Deployment steps

1. Hit the "Deploy to Azure" button above
2. Fill usual fields:
    - Subscription
    - Resource Group: create a new, e.g. Temporary-ImportVHD-FromZIPArchiveURL
    - Region: Azure Region for the resource group
3. Fill the parameters
    - Location: Azure Region where temporary resources will be deployed. Leave as it to use the same region as the Resource Group or set another Azure Region, e.g. francecentral
    - Source: URL of a ZIP Archive containing VHD files
    - Destination: URI of a Storage Account Blob Container to import the VHD files
4. Hit "Review + create", then hit "Create" and wait for the deployment
5. Open the Blob Container in the destination Storage Account resource and verify the VHD Blobs are there
6. Delete the Resource Group if it only contains  temporary resources

## Usage

When the deployment is done, you can start using the .VHD blobs that have been imported in the Storage Account, for example creating Disk or Image resources and then Virtual Machines.

### Demo

This template is used by the [Riverbed Community Cookbooks simple demo for NetIM](https://github.com/riverbed/Riverbed-Community-Toolkit/tree/master/NetIM/Azure-Cloud-Cookbooks/101-netim-simple-demo).

## Notes

`Tags: storage, import, vhd, specialized image`
