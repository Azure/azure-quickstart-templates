---
description: Creates an Azure Storage account and a blob container that can be accessed using SFTP protocol. Access can be password or public-key based.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: storage-sftp
languages:
- bicep
- json
---
# Create Storage Account with SFTP enabled
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-sftp/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-sftp/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-sftp/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-sftp/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-sftp/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-sftp/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.storage/storage-sftp/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.storage%2Fstorage-sftp%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.storage%2Fstorage-sftp%2Fazuredeploy.json)

This template creates an Azure Storage account and a blob container that can be accessed using SFTP protocol. Access can be password or public-key based.

If using password authentication, you will need to access to the storage account in Azure Portal to securely generate a password for the user.

If you are new to Azure Storage account, see:

- [Azure Storage account documentation](http://azure.microsoft.com/documentation/articles/storage-create-storage-account/)
- [Azure Storage account template reference](https://docs.microsoft.com/azure/templates/microsoft.storage/allversions)
- [SSH File Transfer Protocol (SFTP) support for Azure Blob Storage](https://docs.microsoft.com/azure/storage/blobs/secure-file-transfer-protocol-support)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Storage&pageNumber=1&sort=Popular)

If you are new to the template development, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

Tags: Azure Storage account, Resource Manager, Resource Manager templates, ARM templates, SFTP

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Storage/storageAccounts/blobServices/containers, Microsoft.Storage/storageAccounts/localUsers`
