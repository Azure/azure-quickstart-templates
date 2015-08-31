# Simple deployment of an Ubuntu VM with Custom Script extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-customscript-extension-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template shows a simple example abouht how to deploy [CustomScript extension](https://github.com/Azure/azure-linux-extensions/tree/master/CustomScript) to an Linux VM.

## Parameters

| Name   | Description    |
|:--- |:---|
| location  | The location where the Virtual Machine will be deployed | 
| username  | Username for the Virtual Machine  |
| password  | Password for the Virtual Machine  |
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed |
| dnsNameForPublicIP | Unique DNS Name for the Public IP used to access the Virtual Machine |
| fileUris | The uris of files. Splited by blank |
| commandToExecute | The command to execute |
| storageAccountName | The name of storage account |
| storageAccountKey | The access key of storage account |

## Deploy

Azure CLI or Powershell is recommended to deploy the template. And Azure Portal cannot ignore the optional parameters.

1. Using Azure CLI

  https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-azure-resource-manager/

2. Using Powershell

  https://azure.microsoft.com/en-us/documentation/articles/powershell-azure-resource-manager/
