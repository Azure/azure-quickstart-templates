---
description: This template deploys an Ubuntu Virtual Machine Scale Set and uses a custom script extension to connect each VM to an Azure Files share
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vmss-azure-files-linux
languages:
- bicep
- json
---
# Deploy a VMSS that connects each VM to an Azure Files share

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-azure-files-linux/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-azure-files-linux/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-azure-files-linux/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-azure-files-linux/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-azure-files-linux/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-azure-files-linux/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-azure-files-linux/BicepVersion.svg)

This template demonstrates using Azure File with virtual machine scale sets on Ubuntu. Every VM in this scale set will have a mounted Azure Files file share at the location you specify, and a symbolic link will also be created in the user's home directory.

## Prerequisites

In order to run this template you need to create a storage account and file share in advance, which you will pass in as parameters. This template expects the following parameters (in addition to scale set name, capacity etc.):

1. Storage Account Name
2. Storage Account Key
3. File Share Name
4. Mount point

## Step1: To create an Azure Storage Account

* [How to create a Storage Account](https://docs.microsoft.com/azure/storage/storage-create-storage-account#create-a-storage-account)
* [How to create Azure File Share](https://docs.microsoft.com/azure/storage/storage-dotnet-how-to-use-files#use-the-azure-portal-to-manage-a-file-share)

## Step 2: Run this template with parameters

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-azure-files-linux%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-azure-files-linux%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-azure-files-linux%2Fazuredeploy.json)

`Tags: Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/loadBalancers, Microsoft.Compute/virtualMachineScaleSets, CustomScript`
