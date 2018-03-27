# Create a Storage Account and a File Share

Create a Storage Account and a File Share via az-cli in Container Instance

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-aci-storage-file-share%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-aci-storage-file-share%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template demonstrates creating a Storage File Share via az-cli and Azure Container Instance. Modify the template to create a blob or other similar storage operation. The Azure Container Instance and az-cli can be used to create services not directly available in an Azure Resource Manager Template.

`Tags: Azure Container Instance, az-cli`

## Solution overview and deployed resources

The following resources are deployed as part of the solution

+ **Storage Account**: Storage account for the file share
+ **Azure Container Instance**: Azure Container Instance, where the az-cli is exectued to create the file share
+ **File share**: [Azure File share](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction) accessiable via SMB protocol

## Deployment steps

You can click the "Deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

#### Mount

Mount via SMB protocol on [Windows](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows), [Linux](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux), [macOS](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-mac) or [Azure Container Instance](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-volume-azure-files)

## Notes
Azure Container Instance is available in selected [locations](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quotas#region-availability). Please use one of the available location for Azure Container Instance resource.
